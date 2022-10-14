# standardSQL
# hreflang link tag usage
# returns all the data we need from _wpt_bodies
CREATE TEMPORARY FUNCTION getHreflangWptBodies(wpt_bodies_string STRING)
RETURNS STRUCT<
  hreflangs ARRAY<STRING>
> LANGUAGE js AS '''
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
''';

select
    client,
    normalize_and_casefold(hreflang) as hreflang,
    total,
    count(0) as count,
    safe_divide(count(0), total) as pct
from
    (
        select
            _table_suffix as client,
            total,
            gethreflangwptbodies(
                json_extract_scalar(payload, '$._wpt_bodies')
            ) as hreflang_wpt_bodies_info
        from `httparchive.pages.2021_07_01_*`
        join
            (
                select _table_suffix, count(0) as total
                from `httparchive.pages.2021_07_01_*`
                group by _table_suffix
            ) using (_table_suffix)
    ),
    unnest(hreflang_wpt_bodies_info.hreflangs) as hreflang
group by total, hreflang, client
order by count desc, client desc
