# standardSQL
# Workbox usage - based on 2019/14_05.sql
select client, count(distinct page) as freq, total, count(distinct page) / total as pct
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
        regexp_extract_all(
            body, r'(?i)new workbox|workbox\.precaching\.|workbox\.strategies\.'
        )
    ) as occurrence
where date = '2020-08-01'
group by client, total
order by freq / total desc
