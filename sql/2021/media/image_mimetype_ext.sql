# standardSQL
# images mimetype vs extension
select
    client,
    ext,
    mimetype,
    count(0) as ext_mime_image_count,
    sum(count(0)) over (partition by client) as total_images,
    safe_divide(count(0), sum(count(0)) over (partition by client)) as total_image_pct,
    safe_divide(count(0), sum(count(0)) over (partition by client, ext)) as ext_pct,
    safe_divide(
        count(0), sum(count(0)) over (partition by client, mimetype)
    ) as mime_pct
from `httparchive.almanac.requests`
where date = '2021-07-01' and type = 'image'
group by client, ext, mimetype
having ext_mime_image_count > 10000
order by ext_mime_image_count desc, client
