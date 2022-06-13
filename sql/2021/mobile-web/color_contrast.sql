# standardSQL
# % mobile pages with sufficient text color contrast with its background
select
    countif(color_contrast_score is not null) as total_applicable,
    countif(cast(color_contrast_score as numeric) = 1) as total_sufficient,
    countif(cast(color_contrast_score as numeric) = 1) / countif(
        color_contrast_score is not null
    ) as pct_in_applicable
from
    (
        select
            json_extract_scalar(
                report, '$.audits.color-contrast.score'
            ) as color_contrast_score
        from `httparchive.lighthouse.2021_07_01_mobile`
    )
