# standardSQL
# 11_03b: Distribution of SW payload sizes
select
    percentile,
    client,
    approx_quantiles(respsize, 1000) [offset (percentile * 10)] as bytes
from `httparchive.almanac.service_workers` sw
join
    `httparchive.almanac.requests`
    using(date, client, page, url),
    unnest( [10, 25, 50, 75, 90]) as percentile
where sw.date = '2019-07-01'
group by percentile, client
order by percentile, client
