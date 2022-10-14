# standardSQL
# 01_07: Cumulative V8 main thread time
CREATE TEMPORARY FUNCTION totalMainThreadTime(payload STRING)
RETURNS FLOAT64 LANGUAGE js AS '''
try {
  var $ = JSON.parse(payload);
  return Object.values($._v8Stats.main_thread).reduce((sum, i) => sum + i, 0);
} catch (e) {
  return null;
}
''';

select
    client,
    round(approx_quantiles(v8_time, 1000)[offset(100)], 3) as p10,
    round(approx_quantiles(v8_time, 1000)[offset(250)], 3) as p25,
    round(approx_quantiles(v8_time, 1000)[offset(500)], 3) as p50,
    round(approx_quantiles(v8_time, 1000)[offset(750)], 3) as p75,
    round(approx_quantiles(v8_time, 1000)[offset(900)], 3) as p90
from
    (
        select _table_suffix as client, totalmainthreadtime(payload) as v8_time
        from `httparchive.pages.2019_07_01_*`
    )
group by client
