# standardSQL
# pages almanac metrics grouped by device and element attributes being used (present)
CREATE TEMP FUNCTION AS_PERCENT (freq FLOAT64, total FLOAT64) RETURNS FLOAT64 AS (
  ROUND(SAFE_DIVIDE(freq, total), 4)
);

CREATE TEMPORARY FUNCTION get_almanac_attribute_names(almanac_string STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
try {
    var almanac = JSON.parse(almanac_string);

    if (Array.isArray(almanac) || typeof almanac != 'object') return [];

    if (almanac.attributes_used_on_elements) {
      return Object.keys(almanac.attributes_used_on_elements);
    }

} catch (e) {

}
return [];
''';

select
    _table_suffix as client,
    attribute_name,
    count(distinct url) as pages,
    total,
    as_percent(count(distinct url), total) as pct_m401
from `httparchive.pages.2020_08_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2020_08_01_*`
        # to get an accurate total of pages per device. also seems fast
        group by _table_suffix
    ) using (_table_suffix),
    unnest(
        get_almanac_attribute_names(json_extract_scalar(payload, '$._almanac'))
    ) as attribute_name
group by client, total, attribute_name
order by pages / total desc, client
limit 1000
