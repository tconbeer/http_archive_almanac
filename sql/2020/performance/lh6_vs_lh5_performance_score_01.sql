# standardSQL
# Calculates percentile for delta of LH5 and LH6 performance score for mobile
select
    percentile,
    approx_quantiles(
        perf_score_delta, 1000) [offset (percentile * 10)
    ] as perf_score_delta
from
    (
        select perf_score_lh6 - perf_score_lh5 as perf_score_delta
        from
            (
                select
                    cast(
                        json_extract(
                            lh6.report, '$.categories.performance.score'
                        ) as numeric
                    ) as perf_score_lh6,
                    cast(
                        json_extract(
                            lh5.report, '$.categories.performance.score'
                        ) as numeric
                    ) as perf_score_lh5
                from `httparchive.lighthouse.2020_09_01_mobile` lh6
                join `httparchive.lighthouse.2019_07_01_mobile` lh5 on lh5.url = lh6.url
            )
    ),
    unnest( [0, 10, 25, 50, 75, 90, 100]) as percentile
group by percentile
order by percentile
