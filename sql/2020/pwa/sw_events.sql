# standardSQL
# SW events - based on 2019/14_03.sql
select
    client,
    event,
    count(distinct page) as freq,
    total,
    count(distinct page) / total as pct
from `httparchive.almanac.service_workers`
join
    (
        select client, count(distinct page) as total
        from `httparchive.almanac.service_workers`
        where date = '2020-08-01'
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
where date = '2020-08-01'
group by client, total, event
order by freq / total desc
