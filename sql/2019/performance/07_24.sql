# standardSQL
# 07_24: Percentiles of lighthouse performance score
# This metric comes from Lighthouse only
select percentile, approx_quantiles(score, 1000) [offset (percentile * 10)] as score
from
    (
        select
            cast(
                json_extract(report, '$.categories.performance.score') as numeric
            ) as score
        from `httparchive.lighthouse.2019_07_01_mobile`
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile
order by percentile
