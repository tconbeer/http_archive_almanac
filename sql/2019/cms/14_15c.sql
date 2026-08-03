# standardSQL
# 14_15c: Requests and weight of third party content on CMS pages, by category
select
    percentile,
    client,
    category,
    approx_quantiles(requests, 1000)[offset(percentile * 10)] as requests,
    round(approx_quantiles(bytes, 1000)[offset(percentile * 10)] / 1024, 2) as kbytes
from
    (
        select client, category, count(0) as requests, sum(respsize) as bytes
        from `httparchive.almanac.summary_requests` r
        join
            (
                select _table_suffix as client, url as page
                from `httparchive.technologies.2019_07_01_*`
                where category = 'CMS'
            ) using (client, page)
        join `httparchive.almanac.third_parties` tp on net.host(url) = domain
        where r.date = '2019-07-01' and tp.date = '2019-07-01'
        group by client, category, page
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client, category
order by percentile, client, requests desc
