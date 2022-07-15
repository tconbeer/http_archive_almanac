# standardSQL
# Distribution of the number of preconnect audit warnings per page
select
    percentile,
    approx_quantiles(
        array_length(
            json_extract_array(report, '$.audits.uses-rel-preconnect.warnings')
        ),
        1000
    ) [offset (percentile * 10)
    ] as warnings
from
    `httparchive.lighthouse.2020_08_01_mobile`,
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by percentile
order by percentile
