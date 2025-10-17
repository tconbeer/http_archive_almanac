# standardSQL
# 06_32: Top font hosts
select *
from
    (
        select
            client,
            net.host(url) as host,
            count(0) as freq,
            sum(count(0)) over (partition by client) as total,
            round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
        from `httparchive.almanac.requests`
        where date = '2019-07-01' and type = 'font'
        group by client, host
        order by freq / total desc
    )
limit 100
