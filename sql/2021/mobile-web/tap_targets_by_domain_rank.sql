# standardSQL
# % mobile pages with correctly sized tap targets by domain rank (note: the score is
# not binary)
select
    rank_grouping,

    countif(tap_targets_score is not null) as total_applicable,
    countif(cast(tap_targets_score as numeric) = 1) as total_sufficient,
    countif(cast(tap_targets_score as numeric) = 1)
    / countif(tap_targets_score is not null) as pct_in_applicable
from
    (
        select
            url,
            json_extract_scalar(
                report, '$.audits.tap-targets.score'
            ) as tap_targets_score
        from `httparchive.lighthouse.2021_07_01_mobile`
    )
left join
    (
        select url, rank_grouping
        from
            `httparchive.summary_pages.2021_07_01_mobile`,
            unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
        where rank <= rank_grouping
    ) using(url
    )
group by rank_grouping
