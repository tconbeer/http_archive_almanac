# standardSQL
# Distribution of SW payload sizes - based on 2019/14_03b.sql
select
    date,
    percentile,
    client,
    approx_quantiles(respsize, 1000) [offset (percentile * 10)] as bytes
from
    (select distinct date, client, page, url from `httparchive.almanac.service_workers`)
join
    `httparchive.almanac.requests`
    using(date, client, page, url),
    unnest( [10, 25, 50, 75, 90]) as percentile
where date = '2020-08-01'
group by date, percentile, client
order by date, percentile, client
