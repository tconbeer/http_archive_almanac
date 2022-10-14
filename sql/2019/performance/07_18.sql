# standardSQL
# 07_18: Percentiles of blocking JS requests
# This metric comes from Lighthouse only
CREATE TEMPORARY FUNCTION renderBlockingJS(report STRING)
RETURNS STRUCT<requests NUMERIC, bytes NUMERIC, wasted_ms NUMERIC> LANGUAGE js AS '''
try {
  var $ = JSON.parse(report);
  return $.audits['render-blocking-resources'].details.items.filter(item => {
    return item.url.toLowerCase().includes('.js');
  }).reduce((summary, item) => {
    summary.requests++;
    summary.bytes += item.totalBytes;
    summary.wasted_ms += item.wastedMs;
    return summary;
  }, {requests: 0, bytes: 0, wasted_ms: 0});;
} catch (e) {
  return null;
}
''';

select
    percentile,
    approx_quantiles(render_blocking_js.requests, 1000)[
        offset(percentile * 10)
    ] as requests,
    round(
        approx_quantiles(render_blocking_js.bytes, 1000)[offset(percentile * 10)]
        / 1024,
        2
    ) as kbytes,
    round(
        approx_quantiles(render_blocking_js.wasted_ms, 1000)[offset(percentile * 10)]
        / 1000,
        2
    ) as wasted_sec
from
    (
        select renderblockingjs(report) as render_blocking_js
        from `httparchive.lighthouse.2019_07_01_mobile`
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile
order by percentile
