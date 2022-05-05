# standardSQL
# 14_15d: Requests and weight of all content on CMS pages
select
    percentile,
    client,
    approx_quantiles(requests, 1000) [offset (percentile * 10)] as requests,
    round(
        approx_quantiles(bytes, 1000) [offset (percentile * 10)] / 1024 / 1024, 2
    ) as mbytes
from
    (
        select client, count(0) as requests, sum(respsize) as bytes
        from `httparchive.almanac.summary_requests`
        join
            (
                select _table_suffix as client, url as page
                from `httparchive.technologies.2019_07_01_*`
                where category = 'CMS'
            )
            using
            (client, page)
        where date = '2019-07-01'
        group by client, page
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
