# standardSQL
# page wpt_bodies metrics grouped by device and structured data type
# helper to create percent fields
create temp function as_percent(freq float64, total float64)
returns float64
as (round(safe_divide(freq, total), 4))
;

# returns all the data we need from _wpt_bodies
create temporary function get_wpt_bodies_info(wpt_bodies_string string)
returns struct<jsonld_and_microdata_types array<string>>
language js
as '''
var result = {};


try {
    var wpt_bodies = JSON.parse(wpt_bodies_string);

    if (Array.isArray(wpt_bodies) || typeof wpt_bodies != 'object') return result;

    if (wpt_bodies.structured_data && wpt_bodies.structured_data.rendered) {
        var temp = wpt_bodies.structured_data.rendered.jsonld_and_microdata_types;
        result.jsonld_and_microdata_types = temp.map(a => a.name);
    }

} catch (e) {}
return result;
'''
;

select client, type, total, count(0) as count, as_percent(count(0), total) as pct

from
    (
        select
            _table_suffix as client,
            total,
            get_wpt_bodies_info(
                json_extract_scalar(payload, '$._wpt_bodies')
            ) as wpt_bodies_info
        from `httparchive.pages.2020_08_01_*`
        join
            (
                select _table_suffix, count(0) as total
                from `httparchive.pages.2020_08_01_*`
                # to get an accurate total of pages per device. also seems fast
                group by _table_suffix
            ) using (_table_suffix)
    ),
    unnest(wpt_bodies_info.jsonld_and_microdata_types) as type
group by total, type, client
having count > 100
order by count desc
