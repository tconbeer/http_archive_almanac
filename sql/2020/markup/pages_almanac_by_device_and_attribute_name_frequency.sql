# standardSQL
# pages almanac metrics grouped by device and element attribute use (frequency)
CREATE TEMP FUNCTION AS_PERCENT (freq FLOAT64, total FLOAT64) RETURNS FLOAT64 AS (
  ROUND(SAFE_DIVIDE(freq, total), 4)
);

CREATE TEMPORARY FUNCTION get_almanac_attribute_info(almanac_string STRING)
RETURNS ARRAY<STRUCT<name STRING, freq INT64>> LANGUAGE js AS '''
try {
    var almanac = JSON.parse(almanac_string);

    if (Array.isArray(almanac) || typeof almanac != 'object') return [];

    if (almanac.attributes_used_on_elements) {
      return Object.entries(almanac.attributes_used_on_elements).map(([name, freq]) => ({name, freq}));
    }

} catch (e) {

}
return [];
''';

select
    _table_suffix as client,
    almanac_attribute_info.name,
    sum(almanac_attribute_info.freq) as freq,  # total count from all pages
    as_percent(
        sum(almanac_attribute_info.freq),
        sum(sum(almanac_attribute_info.freq)) over (partition by _table_suffix)
    ) as pct_m400
from
    `httparchive.pages.2020_08_01_*`,
    unnest(
        get_almanac_attribute_info(json_extract_scalar(payload, '$._almanac'))
    ) as almanac_attribute_info
group by client, almanac_attribute_info.name
order by freq desc, client
limit 1000
