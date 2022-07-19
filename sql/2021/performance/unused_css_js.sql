# standardSQL
# Distribution of unused CSS and JS
select
    percentile,
    approx_quantiles(
        cast(
            json_extract_scalar(
                report, '$.audits.unused-javascript.details.overallSavingsBytes'
            ) as int64
        )
        / 1024,
        1000
    )[offset(percentile * 10)] as js_kilobytes,
    approx_quantiles(
        cast(
            json_extract_scalar(
                report, '$.audits.unused-css-rules.details.overallSavingsBytes'
            ) as int64
        )
        / 1024,
        1000
    )[offset(percentile * 10)] as css_kilobytes
from
    `httparchive.lighthouse.2021_07_01_mobile`,
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by percentile
order by percentile
