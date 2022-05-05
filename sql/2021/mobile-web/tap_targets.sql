# standardSQL
# % mobile pages with correctly sized tap targets (note: the score is not binary)
select
    countif(tap_targets_score is not null) as total_applicable,
    countif(cast(tap_targets_score as numeric) = 1) as total_sufficient,
    countif(cast(tap_targets_score as numeric) = 1) / countif(
        tap_targets_score is not null
    ) as pct_in_applicable
from
    (
        select
            json_extract_scalar(
                report, '$.audits.tap-targets.score'
            ) as tap_targets_score
        from `httparchive.lighthouse.2021_07_01_mobile`
    )
