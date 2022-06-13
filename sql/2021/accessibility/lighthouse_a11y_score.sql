# standardSQL
# Percentiles of lighthouse a11y score from 2019 - 2021
select
    '2019_07_01' as date,
    percentile,
    approx_quantiles(score, 1000) [offset (percentile * 10)] as score
from
    (
        select
            cast(
                json_extract(report, '$.categories.accessibility.score') as numeric
            ) as score
        from `httparchive.lighthouse.2019_07_01_mobile`
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by date, percentile

union all

select
    '2020_08_01' as date,
    percentile,
    approx_quantiles(score, 1000) [offset (percentile * 10)] as score
from
    (
        select
            cast(
                json_extract(report, '$.categories.accessibility.score') as numeric
            ) as score
        from `httparchive.lighthouse.2020_08_01_mobile`
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by date, percentile

union all

select
    '2021_07_01' as date,
    percentile,
    approx_quantiles(score, 1000) [offset (percentile * 10)] as score
from
    (
        select
            cast(
                json_extract(report, '$.categories.accessibility.score') as numeric
            ) as score
        from `httparchive.lighthouse.2021_07_01_mobile`
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by date, percentile

order by date, percentile
