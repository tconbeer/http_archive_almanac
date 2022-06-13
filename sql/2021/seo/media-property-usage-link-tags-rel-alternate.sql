# standardSQL
# Media property usage of link tags with rel=alternate
# returns all the data we need from _almanac
create temporary function getmediapropertyalmanacinfo(almanac_string string)
returns array
< string
>
language js
as '''
var result = [];
try {
    var almanac = JSON.parse(almanac_string);

    if (Array.isArray(almanac) || typeof almanac != 'object') return ["NO PAYLOAD"];

    if (almanac && almanac["link-nodes"] && almanac["link-nodes"].nodes && almanac["link-nodes"].nodes.filter) {
      result = almanac["link-nodes"].nodes.filter(n => n.rel && n.rel.split(' ').find(r => r.trim().toLowerCase() == 'alternate') && n.media).map(am => am.media.toLowerCase().trim().replace("d(", "d (").replace(": ", ":"));
    }

    if (result.length === 0)
        result.push("NO TAG");

} catch (e) {result.push("ERROR "+e);} // results show some issues with the validity of the payload
return result;
'''
;

select client, media, total, count(0) as count, safe_divide(count(0), total) as pct
from
    (
        select
            _table_suffix as client,
            total,
            getmediapropertyalmanacinfo(
                json_extract_scalar(payload, '$._almanac')
            ) as media_property_almanac_info
        from `httparchive.pages.2021_07_01_*`
        join
            (

                select _table_suffix, count(0) as total
                from `httparchive.pages.2021_07_01_*`
                group by _table_suffix
            )
            using(_table_suffix)
    ),
    unnest(media_property_almanac_info) as media
group by total, media, client
order by count desc
limit 1000
