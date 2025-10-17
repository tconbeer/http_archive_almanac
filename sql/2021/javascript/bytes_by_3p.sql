# standardSQL
# Distribution of 1P/3P JS bytes
select
    percentile,
    client,
    host,
    approx_quantiles(kbytes, 1000)[offset(percentile * 10)] as kbytes
from
    (
        select
            client,
            page,
            if(
                net.host(url) in (
                    select domain
                    from `httparchive.almanac.third_parties`
                    where date = '2021-07-01' and category != 'hosting'
                ),
                'third party',
                'first party'
            ) as host,
            sum(respsize) / 1024 as kbytes
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and type = 'script'
        group by client, page, host
    ),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client, host
order by percentile, client, host
