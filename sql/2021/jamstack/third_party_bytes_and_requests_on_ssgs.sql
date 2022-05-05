# standardSQL
# Third party bytes and requests on SSGs
select
    percentile,
    client,
    approx_quantiles(requests, 1000) [offset (percentile * 10)] as requests,
    approx_quantiles(bytes, 1000) [offset (percentile * 10)] / 1024 as kbytes
from
    (
        select client, count(0) as requests, sum(respsize) as bytes
        from
            (
                select client, page, url, respsize
                from `httparchive.almanac.requests`
                where date = '2021-07-01'
            )
        join
            (
                select distinct _table_suffix as client, url as page
                from `httparchive.technologies.2021_07_01_*`
                where
                    lower(
                        category
                    ) = 'static site generator' or app = 'Next.js' or app = 'Nuxt.js'
            )
            using
            (client, page)
        where
            net.host(url) in (
                select domain
                from `httparchive.almanac.third_parties`
                where date = '2021-07-01' and category != 'hosting'
            )
        group by client, page
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
