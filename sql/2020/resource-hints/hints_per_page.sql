# standardSQL
# 21_02: Distribution of number of times each hint is used per site.
CREATE TEMPORARY FUNCTION getResourceHints(payload STRING)
RETURNS STRUCT<preload INT64, prefetch INT64, preconnect INT64, prerender INT64, `dns-prefetch` INT64>
LANGUAGE js AS '''
var hints = ['preload', 'prefetch', 'preconnect', 'prerender', 'dns-prefetch'];
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return hints.reduce((results, hint) => {
    // Null values are omitted from BigQuery aggregations.
    // This means only pages with at least one hint are considered.
    results[hint] = almanac['link-nodes'].nodes.filter(link => link.rel.toLowerCase() == hint).length || null;
    return results;
  }, {});
} catch (e) {
  return hints.reduce((results, hint) => {
    results[hint] = null;
    return results;
  }, {});
}
''';

select
    percentile,
    client,
    approx_quantiles(hints.preload, 1000)[offset(percentile * 10)] as preload,
    approx_quantiles(hints.prefetch, 1000)[offset(percentile * 10)] as prefetch,
    approx_quantiles(hints.preconnect, 1000)[offset(percentile * 10)] as preconnect,
    approx_quantiles(hints.prerender, 1000)[offset(percentile * 10)] as prerender,
    approx_quantiles(hints.`dns-prefetch`, 1000)[
        offset(percentile * 10)
    ] as dns_prefetch
from
    (
        select _table_suffix as client, getresourcehints(payload) as hints
        from `httparchive.pages.2020_08_01_*`
    ),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
