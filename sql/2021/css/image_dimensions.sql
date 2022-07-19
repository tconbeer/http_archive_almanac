# standardSQL
# CSS-initiated image px dimensions
select
    percentile,
    client,
    approx_quantiles(height, 1000)[offset(percentile * 10)] as height,
    approx_quantiles(width, 1000)[offset(percentile * 10)] as width,
    approx_quantiles(area, 1000)[offset(percentile * 10)] as area
from
    (
        select client, height, width, height * width as area
        from
            (
                select
                    client,
                    page,
                    url as img_url,
                    json_value(payload, '$._initiator') as css_url
                from `httparchive.almanac.requests`
                where date = '2021-07-01' and type = 'image'
            )
        join
            (
                select client, page, url as css_url
                from `httparchive.almanac.requests`
                where date = '2021-07-01' and type = 'css'
            )
            using
            (client, page, css_url)
        join
            (
                select
                    _table_suffix as client,
                    url as page,
                    json_extract_scalar(image, '$.url') as img_url,
                    safe_cast(
                        json_extract_scalar(image, '$.naturalHeight') as int64
                    ) as height,
                    safe_cast(
                        json_extract_scalar(image, '$.naturalWidth') as int64
                    ) as width
                from
                    `httparchive.pages.2021_07_01_*`,
                    unnest(
                        json_extract_array(
                            json_extract_scalar(payload, '$._Images'), '$'
                        )
                    ) as image
            )
            using
            (client, page, img_url)
    ),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
