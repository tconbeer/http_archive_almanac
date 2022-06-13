# standardSQL
# pages with perfect scores on the properly sized images audit
select
    countif(properly_sized_images_score is not null) as total_applicable,
    countif(properly_sized_images_score = 1) as total_with_properly_sized_images,
    countif(properly_sized_images_score = 1) / countif(
        properly_sized_images_score is not null
    ) as pct_with_properly_sized_images
from
    (
        select
            safe_cast(
                json_extract_scalar(
                    report, '$.audits.uses-responsive-images.score'
                ) as numeric
            ) as properly_sized_images_score
        from `httparchive.lighthouse.2021_07_01_mobile`
    )
