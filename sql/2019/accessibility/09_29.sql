# standardSQL
# 09_29: Sites with sufficient text color contrast with its background
select
    count(0) as total_sites,
    countif(color_contrast_score is not null) as total_applicable,
    countif(cast(color_contrast_score as numeric) = 1) as total_sufficient,
    round(
        countif(cast(color_contrast_score as numeric) = 1) * 100 / countif(
            color_contrast_score is not null
        ),
        2
    ) as perc_in_applicable,
    round(
        countif(cast(color_contrast_score as numeric) = 1) * 100 / count(0), 2
    ) as perc_in_all_sites
from
    (
        select
            json_extract_scalar(
                report, '$.audits.color-contrast.score'
            ) as color_contrast_score
        from `httparchive.lighthouse.2019_07_01_mobile`
    )
