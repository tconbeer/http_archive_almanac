# standardSQL
# Usage of native lazy loading
select
    client,
    countif(total_img > 0) as sites_with_images,

    countif(total_loading_attribute > 0) as sites_using_loading_attribute,
    countif(total_loading_attribute > 0)
    / countif(total_img > 0) as pct_sites_using_loading_attribute
from
    (
        select
            _table_suffix as client,
            safe_cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'), '$.images.imgs.total'
                ) as int64
            ) as total_img,
            safe_cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'),
                    '$.images.imgs.attribute_usage_count.loading'
                ) as int64
            ) as total_loading_attribute
        from `httparchive.pages.2020_08_01_*`
    )
group by client
