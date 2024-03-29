# standardSQL
# 13_09e: Requests and weight of all content on ecom pages by type
select
    percentile,
    client,
    type,
    approx_quantiles(requests, 1000)[offset(percentile * 10)] as requests,
    round(approx_quantiles(bytes, 1000)[offset(percentile * 10)] / 1024, 2) as kbytes
from
    (
        select client, type, count(0) as requests, sum(respsize) as bytes
        from `httparchive.almanac.requests`
        join
            (
                select _table_suffix as client, url as page
                from `httparchive.technologies.2020_08_01_*`
                where category = 'Ecommerce'
            ) using (client, page)
        where date = '2020-08-01'
        group by client, type, page
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client, type
order by percentile, client, kbytes desc
