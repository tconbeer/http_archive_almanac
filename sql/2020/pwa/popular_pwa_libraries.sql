# standardSQL
# Popular PWA libraries based on unique ImportScript values
# Use popular_pwa_libraries_helper.sql to find libraries to count
select
    date,
    client,
    count(0) as total,
    countif(lower(body) like '%importscript%') as uses_importscript,
    countif(lower(body) like '%workbox%') as workbox,
    countif(lower(body) like '%sw-toolbox%') as sw_toolbox,
    countif(lower(body) like '%firebase%') as firebase,
    countif(lower(body) like '%onesignalsdk%') as onesignalsdk,
    countif(lower(body) like '%najva%') as najva,
    countif(lower(body) like '%upush%') as upush,
    countif(lower(body) like '%cache-polyfill%') as cache_polyfill,
    countif(lower(body) like '%analytics-helper%') as analytics_helper,
    countif(
        lower(body) like '%importscript%'
        and lower(body) not like '%workbox%'
        and lower(body) not like '%sw-toolbox%'
        and lower(body) not like '%firebase%'
        and lower(body) not like '%onesignalsdk%'
        and lower(body) not like '%najva%'
        and lower(body) not like '%upush%'
        and lower(body) not like '%cache-polyfill%'
        and lower(body) not like '%analytics-helper%'
    ) as importscript_nolib,
    countif(
        lower(body) not like '%importscript%'
        and lower(body) not like '%workbox%'
        and lower(body) not like '%sw-toolbox%'
        and lower(body) not like '%firebase%'
        and lower(body) not like '%onesignalsdk%'
        and lower(body) not like '%najva%'
        and lower(body) not like '%upush%'
        and lower(body) not like '%cache-polyfill.js%'
        and lower(body) not like '%analytics-helper.js%'
    ) as none_of_the_above
from
    (
        select date, client, page, body
        from `httparchive.almanac.service_workers`
        group by date, client, page, body
    )
group by date, client
order by date, client
