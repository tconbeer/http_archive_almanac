# standardSQL
# pages containing name attribute values used in meta tags
create temp function as_percent(freq float64, total float64) returns float64 as (
    round(safe_divide(freq, total), 4)
)
;

# returns all the data we need from _almanac
create temporary function get_almanac_info(almanac_string string)
returns array
< string
> language js
as '''
var result = [];
try {
    var almanac = JSON.parse(almanac_string);

    if (Array.isArray(almanac) || typeof almanac != 'object') return [];

    if (almanac && almanac["meta-nodes"] && almanac["meta-nodes"].nodes && almanac["meta-nodes"].nodes.filter) {
      result = almanac["meta-nodes"].nodes
        .filter(n => n["name"]) // just with a name attribute
        .map(am => am["name"].toLowerCase().trim()) // array of the names
        .filter((v, i, a) => a.indexOf(v) === i); // remove duplicates
    }

} catch (e) {} // results show some issues with the validity of the payload
return result;
'''
;

select
    client, meta_tag_name, total, count(0) as count, as_percent(count(0), total) as pct
from
    (
        select
            _table_suffix as client,
            total,
            get_almanac_info(json_extract_scalar(payload, '$._almanac')) as almanac_info
        from `httparchive.pages.2020_08_01_*`
        join
            (
                # to get an accurate total of pages per device. also seems fast
                select _table_suffix, count(0) as total
                from `httparchive.pages.2020_08_01_*`
                group by _table_suffix
            ) using (_table_suffix)
    ),
    unnest(almanac_info) as meta_tag_name
group by total, meta_tag_name, client
order by count desc
limit 1000
