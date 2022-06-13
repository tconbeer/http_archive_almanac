# standardSQL
# Prevalence of values for Server and X-Powered-By headers; count by number of hosts.
select client, type, resp_value, total, freq, pct
from
    (
        select
            client,
            'server' as type,
            resp_server as resp_value,
            sum(count(distinct net.host(page))) over (partition by client) as total,
            count(distinct net.host(page)) as freq,
            count(distinct net.host(page)) / sum(
                count(distinct net.host(page))
            ) over (partition by client) as pct
        from `httparchive.almanac.requests`
        where
            (date = '2020-08-01' or date = '2021-07-01') and
            resp_server is not null and resp_server != ''
        group by client, type, resp_server
        order by freq desc
        limit 40
    )
union all
(
    select
        client,
        'x-powered-by' as type,
        resp_x_powered_by as resp_value,
        sum(count(distinct net.host(page))) over (partition by client) as total,
        count(distinct net.host(page)) as freq,
        count(distinct net.host(page)) / sum(
            count(distinct net.host(page))
        ) over (partition by client) as pct
    from `httparchive.almanac.requests`
    where
        (date = '2020-08-01' or date = '2021-07-01') and
        resp_x_powered_by is not null and resp_x_powered_by != ''
    group by client, type, resp_x_powered_by
    order by freq desc
    limit 40
)
order by client, type, freq desc
