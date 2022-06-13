# standardSQL
# 16_01: TTL by resource
select
    client,
    percentile,
    type,
    approx_quantiles(expage, 1000) [offset (percentile * 10)] as ttl
from `httparchive.almanac.requests`, unnest( [10, 25, 50, 75, 90]) as percentile
where date = '2019-07-01' and expage > 0
group by percentile, client, type
order by type, percentile, client
