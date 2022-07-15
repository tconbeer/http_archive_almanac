# standardSQL
# Sites that have associated labels for their form elements
select
    count(0) as total_sites,
    countif(label_score is not null) as total_applicable,
    countif(cast(label_score as numeric) = 1) as total_sufficient,
    countif(cast(label_score as numeric) = 1)
    / countif(label_score is not null) as perc_in_applicable
from
    (
        select json_extract_scalar(report, '$.audits.label.score') as label_score
        from `httparchive.lighthouse.2021_07_01_mobile`
    )
