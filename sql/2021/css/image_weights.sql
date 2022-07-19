# standardSQL
# CSS-initiated image stats per page (count, weight)
select
    percentile,
    client,
    approx_quantiles(css_initiated_images_per_page, 1000)[
        offset(percentile * 10)
    ] as css_initiated_images_per_page,
    approx_quantiles(total_css_initiated_image_weight_per_page, 1000)[
        offset(percentile * 10)
    ] as total_css_initiated_image_weight_per_page
from
    (
        select
            client,
            count(0) as css_initiated_images_per_page,
            sum(respsize) as total_css_initiated_image_weight_per_page
        from
            (
                select
                    client, page, json_value(payload, '$._initiator') as url, respsize
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
        group by client, page
    ),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
