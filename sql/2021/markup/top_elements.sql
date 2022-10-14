# standardSQL
# Top used elements
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
    sum(element_type_info.freq) as freq,  # total count from all pages
    sum(element_type_info.freq)
    / sum(sum(element_type_info.freq)) over (partition by _table_suffix) as pct
from
    `httparchive.pages.2021_07_01_*`,
    unnest(
        get_element_types_info(json_extract_scalar(payload, '$._element_count'))
    ) as element_type_info
group by client, element_type_info.name
order by pct desc, client, freq desc
limit 1000
