# standardSQL
# 19_02: Distribution of number of times each hint is used per site.
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
    results[hint] = almanac['link-nodes'].filter(link => link.rel.toLowerCase() == hint).length || null;
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
    client,
    approx_quantiles(hints.preload, 1000)[offset(500)] as median_preload,
    approx_quantiles(hints.prefetch, 1000)[offset(500)] as median_prefetch,
    approx_quantiles(hints.preconnect, 1000)[offset(500)] as median_preconnect,
    approx_quantiles(hints.prerender, 1000)[offset(500)] as median_prerender,
    approx_quantiles(hints.`dns-prefetch`, 1000)[offset(500)] as median_dns_prefetch,
    approx_quantiles(hints.preload, 1000)[offset(900)] as p90_preload,
    approx_quantiles(hints.prefetch, 1000)[offset(900)] as p90_prefetch,
    approx_quantiles(hints.preconnect, 1000)[offset(900)] as p90_preconnect,
    approx_quantiles(hints.prerender, 1000)[offset(900)] as p90_prerender,
    approx_quantiles(hints.`dns-prefetch`, 1000)[offset(900)] as p90_dns_prefetch
from
    (
        select _table_suffix as client, getresourcehints(payload) as hints
        from `httparchive.pages.2019_07_01_*`
    )
group by client
