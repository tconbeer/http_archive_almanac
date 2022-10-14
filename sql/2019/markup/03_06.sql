# standardSQL
# 03_06: Elements per page
CREATE TEMPORARY FUNCTION countElements(payload STRING)
RETURNS INT64 LANGUAGE js AS '''
try {
  var $ = JSON.parse(payload);
  var elements = JSON.parse($._element_count);
  if (Array.isArray(elements) || typeof elements != 'object') return null;
  return Object.values(elements).reduce((total, freq) => total + (parseInt(freq, 10) || 0), 0);
} catch (e) {
  return null;
}
''';

select
    percentile,
    client,
    count(distinct url) as pages,
    approx_quantiles(elements, 1000)[offset(percentile * 10)] as elements,
    cast(round(avg(elements)) as int64) as avg,
    min(elements) as min,
    max(elements) as max
from
    (
        select _table_suffix as client, url, countelements(payload) as elements
        from `httparchive.pages.2019_07_01_*`
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
