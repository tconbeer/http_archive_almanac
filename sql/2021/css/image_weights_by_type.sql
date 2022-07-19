# standardSQL
# CSS-initiated image stats per page (count, weight) by format
select
    percentile,
    client,
    format,
    approx_quantiles(css_initiated_images_per_page, 1000)[
        offset(percentile * 10)
    ] as css_initiated_images_per_page,
    approx_quantiles(total_css_initiated_image_weight_per_page / 1024, 1000)[
        offset(percentile * 10)
    ] as total_css_initiated_image_kbytes_per_page
from
    (
        select
            client,
            format,
            count(0) as css_initiated_images_per_page,
            sum(respsize) as total_css_initiated_image_weight_per_page
        from
            (
                select
                    client,
                    page,
                    json_value(payload, '$._initiator') as url,
                    respsize,
                    format
                from `httparchive.almanac.requests`
                where date = '2021-07-01' and type = 'image'
            )
        join
            (
                select client, page, url
                from `httparchive.almanac.requests`
                where date = '2021-07-01' and type = 'css'
            )
            using
            (client, page, url)
        group by client, page, format
    ),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client, format
order by percentile, client, css_initiated_images_per_page desc
