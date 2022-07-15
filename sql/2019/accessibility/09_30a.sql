# standardSQL
# 09_30a: Sites that have associated labels for their form elements
select
    count(0) as total_sites,
    countif(label_score is not null) as total_applicable,
    countif(cast(label_score as numeric) = 1) as total_sufficient,
    round(
        countif(cast(label_score as numeric) = 1)
        * 100 / countif(
            label_score is not null
        ),
        2
    ) as perc_in_applicable,
    round(
        countif(cast(label_score as numeric) = 1) * 100 / count(0), 2
    ) as perc_in_all_sites
from
    (
        select json_extract_scalar(report, '$.audits.label.score') as label_score
        from `httparchive.lighthouse.2019_07_01_mobile`
    )
