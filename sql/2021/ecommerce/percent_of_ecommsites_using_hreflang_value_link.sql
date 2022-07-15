# standardSQL
# page wpt_bodies metrics grouped by device and hreflang value in link tags
# this also filters for Ecommerce sites
# helper to create percent fields
create temp function
as_percent(freq float64, total float64)
returns float64 as (safe_divide(freq, total))
;
# returns all the data we need from _wpt_bodies
create temporary function
get_wpt_bodies_info(wpt_bodies_string string)
returns struct < hreflangs array < string > >
language js
as '''
var result = {
hreflangs: []
};
try {
    var wpt_bodies = JSON.parse(wpt_bodies_string);
    if (Array.isArray(wpt_bodies) || typeof wpt_bodies != 'object') return result;
    if (wpt_bodies.hreflangs && wpt_bodies.hreflangs.rendered && wpt_bodies.hreflangs.rendered.values) {
        result.hreflangs = wpt_bodies.hreflangs.rendered.values.map(v=> v); // seems to fix a coercion issue!
    }
} catch (e) {}
return result;
'''
;
select
    client,
    normalize_and_casefold(hreflang) as hreflang,
    total,
    count(0) as count,
    as_percent(count(0), total) as pct
from
    (
        select
            _table_suffix as client,
            total,
            get_wpt_bodies_info(
                json_extract_scalar(payload, '$._wpt_bodies')
            ) as wpt_bodies_info
        from `httparchive.pages.2021_07_01_*`
        join
            (
                select _table_suffix, url
                from `httparchive.technologies.2021_07_01_*`
                where
                    category = 'Ecommerce'
                    and (
                        app != 'Cart Functionality'
                        and app != 'Google Analytics Enhanced eCommerce'
                    )
            )
            using
            (_table_suffix, url)
        join
            (
                select _table_suffix, count(0) as total
                from `httparchive.pages.2021_07_01_*`
                # to get an accurate total of pages per device. also seems fast
                group by _table_suffix
            )
            using
            (_table_suffix)
    ),
    unnest(wpt_bodies_info.hreflangs) as hreflang
group by total, hreflang, client
order by count desc, client desc
