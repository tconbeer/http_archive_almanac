# standardSQL
# Distribution of CMS page kilobytes per resource type
select
    percentile,
    client,
    type,
    approx_quantiles(requests, 1000)[offset(percentile * 10)] as requests,
    round(approx_quantiles(bytes, 1000)[offset(percentile * 10)] / 1024, 2) as kbytes
from
    (
        select client, type, count(0) as requests, sum(respsize) as bytes
        from
            (
                select client, page, type, respsize
                from `httparchive.almanac.requests`
                where date = '2020-08-01'
            )
        join
            (
                select _table_suffix as client, url as page
                from `httparchive.technologies.2020_08_01_*`
                where category = 'CMS'
            )
            using
            (client, page)
        group by client, type, page
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client, type
order by percentile, client, kbytes desc
