# standardSQL
# Use of picture, source and srcset
select
    client,
    countif(total_img > 0) as pages_with_images,

    countif(total_picture > 0) as pages_with_picture,
    countif(total_source > 0) as pages_with_source,
    countif(total_srcset > 0) as pages_with_srcset,

    countif(total_picture > 0) / countif(total_img > 0) as pct_pages_with_picture,
    countif(total_source > 0) / countif(total_img > 0) as pct_pages_with_source,
    countif(total_srcset > 0) / countif(total_img > 0) as pct_pages_with_srcset
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'), '$.images.imgs.total'
                ) as int64
            ) as total_img,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'),
                    '$.images.pictures.total'
                ) as int64
            ) as total_picture,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'), '$.images.sources.total'
                ) as int64
            ) as total_source,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'),
                    '$.images.total_with_srcset'
                ) as int64
            ) as total_srcset
        from `httparchive.pages.2021_07_01_*`
    )
group by client
