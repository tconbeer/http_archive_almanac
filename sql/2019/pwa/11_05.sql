# standardSQL
# 11_05: Workbox usage
select
    client,
    count(distinct page) as freq,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from `httparchive.almanac.service_workers` sw
join
    (
        select date, client, count(distinct page) as total
        from `httparchive.almanac.service_workers`
        where date = '2019-07-01'
        group by client
    ) using (date, client),
    unnest(
        regexp_extract_all(
            body, r'new Workbox|new workbox|workbox\.precaching\.|workbox\.strategies\.'
        )
    ) as occurrence
where sw.date = '2019-07-01'
group by client, total
order by freq / total desc
