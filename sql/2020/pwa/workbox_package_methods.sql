# standardSQL
# Workbox package and methods
select
    client,
    workbox_package,
    workbox_method,
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
        array_concat(regexp_extract_all(body, r'workbox\.([a-zA-Z]+\.?[a-zA-Z]*)'))
    ) as workbox,
    unnest(
        array_concat(regexp_extract_all(workbox, r'([a-zA-Z]+)\.?[a-zA-Z]*'))
    ) as workbox_package,
    unnest(
        array_concat(regexp_extract_all(workbox, r'([a-zA-Z]+\.?[a-zA-Z]*)'))
    ) as workbox_method
where
    date = '2020-08-01'
    # Exclude JS files themselves as only interested in functions
    and workbox_method not like ('%js')
    and workbox_method not like ('%js.map')
group by client, total, workbox_package, workbox_method
order by freq / total desc, workbox_package, workbox_method, client
