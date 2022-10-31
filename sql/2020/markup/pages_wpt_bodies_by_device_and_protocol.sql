# standardSQL
# page wpt_bodies metrics grouped by device
# M235
# helper to create percent fields
create temp function as_percent(freq float64, total float64)
returns float64
as (round(safe_divide(freq, total), 4))
;

# returns all the data we need from _wpt_bodies
create temporary function get_wpt_bodies_protocols(wpt_bodies_string string)
returns array<string>
language js
as
    '''
var result = [];
try {
    var wpt_bodies = JSON.parse(wpt_bodies_string);

    if (Array.isArray(wpt_bodies) || typeof wpt_bodies != 'object') return result;

    if (wpt_bodies.anchors && wpt_bodies.anchors.rendered && wpt_bodies.anchors.rendered.protocols) {
        return Object.keys(wpt_bodies.anchors.rendered.protocols);
    }

} catch (e) {}
return result;
'''
;

select
    _table_suffix as client,
    count(distinct url) as pages,
    total,
    protocol,

    as_percent(count(distinct url), total) as pct

from `httparchive.pages.2020_08_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2020_08_01_*`
        # to get an accurate total of pages per device. also seems fast
        group by _table_suffix
    ) using (_table_suffix),
    unnest(
        get_wpt_bodies_protocols(json_extract_scalar(payload, '$._wpt_bodies'))
    ) as protocol
group by client, total, protocol
order by pages desc
limit 1000
