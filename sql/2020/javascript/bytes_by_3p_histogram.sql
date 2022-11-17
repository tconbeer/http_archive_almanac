# standardSQL
# Histogram of JS bytes by 3P
select
    client,
    host,
    if(kbytes < 100, floor(kbytes / 5) * 5, 100) as kbytes,
    count(distinct page) as pages,
    count(0) as requests,
    sum(count(0)) over (partition by client, host) as total,
    count(0) / sum(count(0)) over (partition by client, host) as pct
from
    (
        select
            client,
            page,
            if(
                net.host(url) in (
                    select domain
                    from `httparchive.almanac.third_parties`
                    where date = '2020-08-01' and category != 'hosting'
                ),
                'third party',
                'first party'
            ) as host,
            respsize / 1024 as kbytes
        from `httparchive.almanac.requests`
        where date = '2020-08-01' and type = 'script'
    )
group by client, host, kbytes
order by kbytes, client, host
