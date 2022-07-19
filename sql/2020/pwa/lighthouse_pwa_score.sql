# standardSQL
# Percentiles of lighthouse pwa score
# Based on 07_24: Percentiles of lighthouse performance score
# This metric comes from Lighthouse only and is only available in mobile in HTTP
# Archive dataset
select
    '2019_07_01' as date,
    percentile,
    approx_quantiles(score, 1000)[offset(percentile * 10)] as score
from
    (
        select cast(json_extract(report, '$.categories.pwa.score') as numeric) as score
        from `httparchive.lighthouse.2019_07_01_mobile`
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by date, percentile
union all
select
    '2020_08_01' as date,
    percentile,
    approx_quantiles(score, 1000)[offset(percentile * 10)] as score
from
    (
        select cast(json_extract(report, '$.categories.pwa.score') as numeric) as score
        from `httparchive.lighthouse.2020_08_01_mobile`
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by date, percentile
order by date, percentile
