# standardSQL
# pages almanac metrics grouped by device and element attribute use (frequency)
CREATE TEMP FUNCTION AS_PERCENT (freq FLOAT64, total FLOAT64) RETURNS FLOAT64 AS (
  ROUND(SAFE_DIVIDE(freq, total), 4)
);

CREATE TEMPORARY FUNCTION get_almanac_attribute_info(almanac_string STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
try {
    var almanac = JSON.parse(almanac_string);

    if (Array.isArray(almanac) || typeof almanac != 'object') return [];

    if (almanac.scripts && almanac.scripts.nodes && almanac.scripts.nodes.map) {
      return almanac.scripts.nodes.map(n => {if (n.type) return n.type.toLowerCase().trim(); else return "NOT_SET"; });
    }

} catch (e) {

}
return [];
''';

select
    _table_suffix as client,
    type_name,
    count(0) as freq,
    as_percent(count(0), sum(count(0)) over (partition by _table_suffix)) as pct
from
    `httparchive.pages.2020_08_01_*`,
    unnest(
        get_almanac_attribute_info(json_extract_scalar(payload, '$._almanac'))
    ) as type_name
group by client, type_name
having freq > 1000
order by freq desc, client
