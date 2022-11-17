# standardSQL
# CSS-initiated image px dimension popularity
select *
from
    (
        select
            client,
            height,
            width,
            count(0) as freq,
            sum(count(0)) over (partition by client) as total,
            count(0) / sum(count(0)) over (partition by client) as pct
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
            ) using (client, page, css_url)
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
            ) using (client, page, img_url)
        where height is not null and width is not null
        group by client, height, width
        order by pct desc
    )
limit 500
