# standardSQL
# Counting Manifests and Service Workers
# Currently showing both years but should change to just current year in future
select
    date,
    client,
    manifests / total as manifests_pct,
    serviceworkers / total as serviceworkers_pct,
    either / total as either_pct,
    both / total as both_pct,
    total
from
    (
        select
            date,
            client,
            count(distinct m.page) as manifests,
            count(distinct sw.page) as serviceworkers,
            count(distinct ifnull(m.page, sw.page)) as either,
            count(distinct m.page || sw.page) as both
        from `httparchive.almanac.manifests` m
        full outer join
            `httparchive.almanac.service_workers` sw using (date, client, page)
        group by date, client
    )
join
    (
        select date, client, count(distinct page) as total
        from `httparchive.almanac.summary_requests`
        group by date, client
    ) using (date, client)
order by date, client
