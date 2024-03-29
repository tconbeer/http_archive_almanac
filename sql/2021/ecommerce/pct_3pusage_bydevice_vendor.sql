# standardSQL
# 13_09b: Requests and weight of third party content per app
select
    client,
    app,
    percentile,
    count(0) as pages,
    approx_quantiles(requests, 1000)[offset(percentile * 10)] as requests,
    approx_quantiles(bytes, 1000)[offset(percentile * 10)] / 1024 as kbytes
from
    (
        select client, app, count(0) as requests, sum(respsize) as bytes
        from `httparchive.almanac.requests`
        join
            (
                select _table_suffix as client, url as page, app
                from `httparchive.technologies.2021_07_01_*`
                where category = 'Ecommerce'
            ) using (client, page)
        where
            date = '2021-07-01'
            and net.host(url) in (
                select domain
                from `httparchive.almanac.third_parties`
                where date = '2021-07-01' and category != 'hosting'
            )
        group by client, app, page
    ),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by client, app, percentile
order by pages desc, client, percentile
