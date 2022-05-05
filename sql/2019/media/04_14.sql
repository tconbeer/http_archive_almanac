# standardSQL
# 04_14: Distribution of image network setup times
create temporary function getnetworksetuptime(payload string)
returns int64 language js
as '''
try {
  var $ = JSON.parse(payload);
  var timings = $.timings;
  var time = -1;
  if (timings.dns >= 1) time += timings.dns;
  if (timings.connect >= 1) time += timings.connect;
  if (timings.ssl >= 1) time += timings.ssl;
  return time >= 0 ? time : null;
} catch (e) {
  return null;
}
'''
;

select
    percentile,
    client,
    approx_quantiles(getnetworksetuptime(payload), 1000) [
        offset (percentile * 10)
    ] as network_setup_time
from `httparchive.almanac.requests`, unnest( [10, 25, 50, 75, 90]) as percentile
where date = '2019-07-01' and type = 'image'
group by percentile, client
order by percentile, client
