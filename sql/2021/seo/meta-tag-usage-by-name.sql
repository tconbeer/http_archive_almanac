# standardSQL
# Meta tag usage by name
# returns all the data we need from _almanac
create temporary function getmetatagalmanacinfo(almanac_string string)
returns array
< string
>
language js
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
    client, meta_tag_name, total, count(0) as count, safe_divide(count(0), total) as pct
from
    (
        select
            _table_suffix as client,
            total,
            getmetatagalmanacinfo(
                json_extract_scalar(payload, '$._almanac')
            ) as meta_tag_almanac_info
        from `httparchive.pages.2021_07_01_*`
        join
            (

                select _table_suffix, count(0) as total
                from `httparchive.pages.2021_07_01_*`
                group by _table_suffix
            )
            using(_table_suffix)
    ),
    unnest(meta_tag_almanac_info) as meta_tag_name
group by total, meta_tag_name, client
order by count desc
limit 1000
