# Number of picture elements per page
select
    percentile,
    client,
    countif(picture > 0) as pages,
    count(0) as total,
    countif(picture > 0) / count(0) as pct,
    approx_quantiles(
        if(picture > 0, picture, null), 1000) [offset (percentile * 10)
    ] as picture_elements_per_page
from
    (
        select
            _table_suffix as client,
            cast(
                json_query(
                    json_value(payload, '$._media'), '$.num_picture_img'
                ) as int64
            ) as picture
        from `httparchive.pages.2021_07_01_*`
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
