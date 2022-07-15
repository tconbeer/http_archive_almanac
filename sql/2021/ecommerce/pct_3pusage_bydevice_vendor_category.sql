# standardSQL
# 13_09c: Requests and weight of third party content on ecom pages, by category
select
    percentile,
    client,
    category,
    approx_quantiles(requests, 1000) [offset (percentile * 10)] as requests,
    approx_quantiles(bytes, 1000) [offset (percentile * 10)] / 1024 as kbytes
from
    (
        select client, category, count(0) as requests, sum(respsize) as bytes
        from `httparchive.almanac.requests`
        join
            (
                select distinct _table_suffix as client, url as page
                from `httparchive.technologies.2021_07_01_*`
                where
                    category = 'Ecommerce'
                    and (
                        app != 'Cart Functionality'
                        and app != 'Google Analytics Enhanced eCommerce'
                    )
            )
            using
            (client, page)
        join `httparchive.almanac.third_parties` on net.host(url) = domain
        where `httparchive.almanac.requests`.date = '2021-07-01'
        group by client, category, page
    ),

    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client, category
order by percentile, client, requests desc
