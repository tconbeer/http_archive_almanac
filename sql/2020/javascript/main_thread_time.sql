# standardSQL
# Cumulative V8 main thread time
create temporary function totalmainthreadtime(payload string)
returns float64
language js
as '''
try {
  var $ = JSON.parse(payload);
  return Object.values($._v8Stats.main_thread).reduce((sum, i) => sum + i, 0);
} catch (e) {
  return null;
}
'''
;

select
    percentile,
    client,
    approx_quantiles(v8_time, 1000)[offset(percentile * 10)] as v8_time
from
    (
        select _table_suffix as client, totalmainthreadtime(payload) as v8_time
        from `httparchive.pages.2020_08_01_*`
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
