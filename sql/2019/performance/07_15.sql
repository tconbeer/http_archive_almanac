# standardSQL
# 07_15: Percentiles of first cpu idle
# This metric comes from Lighthouse
select
    percentile,
    round(
        approx_quantiles(first_cpu_idle, 1000)[offset(percentile * 10)] / 1000, 2
    ) as first_cpu_idle
from
    (
        select
            cast(
                ifnull(
                    json_extract(report, '$.audits.first-interactive.numericValue'),
                    json_extract(report, '$.audits.first-cpu-idle.numericValue')
                ) as float64
            ) as first_cpu_idle
        from `httparchive.lighthouse.2019_07_01_mobile`
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile
order by percentile
