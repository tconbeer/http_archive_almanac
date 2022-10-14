# standardSQL
# page almanac favicon image types grouped by device and type M217
CREATE TEMP FUNCTION AS_PERCENT (freq FLOAT64, total FLOAT64) RETURNS FLOAT64 AS (
  ROUND(SAFE_DIVIDE(freq, total), 4)
);

# returns all the data we need from _almanac
CREATE TEMPORARY FUNCTION get_almanac_info(almanac_string STRING)
RETURNS ARRAY<STRING>
LANGUAGE js AS '''
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
''';

select client, media, total, count(0) as count, as_percent(count(0), total) as pct
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
    unnest(almanac_info) as media
group by total, media, client
order by count desc
limit 1000
