# standardSQL
# Use this sql to find popular library imports for popular_pwa_libraries.sql
# And also other importscripts used in service workers
select
    client,
    importscript,
    count(distinct page) as pages,
    total,
    count(distinct page) / total as pct
from (select distinct * from `httparchive.almanac.service_workers`)
join
    (
        select client, date, count(distinct page) as total
        from `httparchive.almanac.service_workers`
        group by client, date
    )
    using(client, date),
    unnest(
        array_concat(
            regexp_extract_all(body, r'(?i)importscripts\([\'"]([^(]*)[\'"]\)')
        )
    ) as importscript
where
    date = '2020-08-01'
    and lower(body) like '%importscripts%'
    and lower(importscript) not like '%workbox%'
    and lower(importscript) not like '%sw-toolbox%'
    and lower(importscript) not like '%firebase%'
    and lower(importscript) not like '%onesignalsdk%'
    and lower(importscript) not like '%najva%'
    and lower(importscript) not like '%upush%'
    and lower(importscript) not like '%ache-polyfill%'
    and lower(importscript) not like '%analytics-helper%'
group by client, importscript, total
order by pct desc, client
