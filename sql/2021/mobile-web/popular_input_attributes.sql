# standardSQL
# % of pages using each input element attribute
CREATE TEMPORARY FUNCTION getUsedAttributes(payload STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
try {
  const almanac = JSON.parse(payload);
  return Object.keys(almanac.input_elements.attribute_usage_count);
} catch (e) {
  return [];
}
''';
select
    _table_suffix as client,
    total_pages,
    attribute,
    count(0) as total_pages_using,
    count(0) / total_pages as pct_pages_using
from
    `httparchive.pages.2021_07_01_*`,
    unnest(getusedattributes(json_extract_scalar(payload, '$._almanac'))) as attribute
left join
    (
        select _table_suffix, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    ) using (_table_suffix)
group by client, attribute, total_pages
having total_pages_using >= 100
order by pct_pages_using desc
