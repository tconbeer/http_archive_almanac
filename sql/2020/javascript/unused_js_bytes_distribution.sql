# standardSQL
# Distribution of unused JS request bytes per page
select
    percentile,
    approx_quantiles(
        cast(
            json_extract_scalar(
                report, '$.audits.unused-javascript.details.overallSavingsBytes'
            ) as int64
        ) / 1024,
        1000
    ) [offset (percentile * 10)] as js_kilobytes
from
    `httparchive.lighthouse.2020_08_01_mobile`,
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by percentile
order by percentile
