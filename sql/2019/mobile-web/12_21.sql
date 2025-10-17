# standardSQL
# 12_21: Sites using webp
select
    client,
    count(0) as total_pages,
    countif(total_images > 0) as total_with_images,
    countif(total_webp > 0) as total_with_webp,
    round(
        countif(total_webp > 0) * 100 / countif(total_images > 0), 2
    ) as total_sites_using_webp
from
    (
        select
            _table_suffix as client,
            pageid,
            countif(type = 'image') as total_images,
            countif(type = 'image' and format = 'webp') as total_webp
        from `httparchive.summary_requests.2019_07_01_*`
        group by client, pageid
    )
group by client
