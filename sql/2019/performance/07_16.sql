# standardSQL
# 07_16: Percentiles of time to interactive
# This metric comes from Lighthouse
select
    percentile,
    round(approx_quantiles(tti, 1000)[offset(percentile * 10)] / 1000, 2) as tti
from
    (
        select
            cast(
                ifnull(
                    json_extract(
                        report, '$.audits.consistently-interactive.numericValue'
                    ),
                    json_extract(report, '$.audits.interactive.numericValue')
                ) as float64
            ) as tti
        from `httparchive.lighthouse.2019_07_01_mobile`
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile
order by percentile
