# standardSQL
# 11_03: SW events
select
    client,
    event,
    count(distinct page) as freq,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from `httparchive.almanac.service_workers`
join
    (
        select client, count(distinct page) as total
        from `httparchive.almanac.service_workers`
        group by client
    )
    using(client),
    unnest(
        array_concat(
            regexp_extract_all(
                body,
                r'\.on(install|activate|fetch|push|notificationclick|notificationclose|sync|canmakepayment|paymentrequest|message|messageerror)\s*='
            ),
            regexp_extract_all(
                body,
                r'addEventListener\(\s*[\'"](install|activate|fetch|push|notificationclick|notificationclose|sync|canmakepayment|paymentrequest|message|messageerror)[\'"]'
            )
        )
    ) as event
where date = '2019-07-01'
group by client, total, event
order by freq / total desc
