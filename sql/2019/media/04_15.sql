# standardSQL
# 04_16: Video format sizes
select
    percentile,
    client,
    format,
    round(approx_quantiles(respsize, 1000)[offset(percentile * 10)] / 1024, 2) as kbytes
from `httparchive.almanac.requests`, unnest([10, 25, 50, 75, 90]) as percentile
where date = '2019-07-01' and type = 'video'
group by percentile, client, format
order by percentile, client, format
