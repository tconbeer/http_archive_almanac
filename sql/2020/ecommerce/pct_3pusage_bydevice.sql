# standardSQL
# 13_09: Requests and weight of third party content on ecom pages
select
    percentile,
    client,
    approx_quantiles(requests, 1000)[offset(percentile * 10)] as requests,
    round(approx_quantiles(bytes, 1000)[offset(percentile * 10)] / 1024, 2) as kbytes
from
    (
        select client, count(0) as requests, sum(respsize) as bytes
        from `httparchive.almanac.requests`
        join
            (
                select distinct _table_suffix as client, url as page
                from `httparchive.technologies.2020_08_01_*`
                where category = 'Ecommerce'
            ) using (client, page)
        where
            date = '2020-08-01'
            and net.host(url) in (
                select domain
                from `httparchive.almanac.third_parties`
                where category != 'hosting'
            )
        group by client, page
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
