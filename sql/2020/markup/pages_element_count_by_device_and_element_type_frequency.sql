# standardSQL
# Top used elements
# See related: sql/2019/03_Markup/03_02b.sql
CREATE TEMP FUNCTION AS_PERCENT (freq FLOAT64, total FLOAT64) RETURNS FLOAT64 AS (
  ROUND(SAFE_DIVIDE(freq, total), 4)
);

CREATE TEMPORARY FUNCTION get_element_types_info(element_count_string STRING)
RETURNS ARRAY<STRUCT<name STRING, freq INT64>> LANGUAGE js AS '''
try {
    if (!element_count_string) return []; // 2019 had a few cases

    var element_count = JSON.parse(element_count_string); // should be an object with element type properties with values of how often they are present

    if (Array.isArray(element_count) || typeof element_count != 'object') return [];

    return Object.entries(element_count).map(([name, freq]) => ({name, freq}));

} catch (e) {
    return [];
}
''';

select
    _table_suffix as client,
    element_type_info.name,
    sum(element_type_info.freq) as freq_m201,  # total count from all pages
    as_percent(
        sum(element_type_info.freq),
        sum(sum(element_type_info.freq)) over (partition by _table_suffix)
    ) as pct_m202
from
    `httparchive.pages.2020_08_01_*`,
    unnest(
        get_element_types_info(json_extract_scalar(payload, '$._element_count'))
    ) as element_type_info
group by client, element_type_info.name
order by freq_m201 desc, client
limit 1000
