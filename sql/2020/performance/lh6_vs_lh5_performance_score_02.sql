# standardSQL
# Calculates percentage of sites where the performance score changed small ( < 10),
# medium (10-30) or large (> 30) between LH 5 and 6 versions.
select
    direction,
    magnitude,
    pages as freq,
    sum(pages) over () as total,
    pages / sum(pages) over () as pct
from
    (
        select
            case
                when perf_score_delta < 0 then 'negative' else 'positive'
            end as direction,
            case
                when abs(perf_score_delta) <= 0.1
                then 'small'
                when abs(perf_score_delta) < 0.3
                then 'large'
                else 'medium'
            end as magnitude,
            count(0) as pages
        from
            (
                select
                    perf_score_lh6,
                    perf_score_lh5,
                    perf_score_lh6 - perf_score_lh5 as perf_score_delta
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
                        from `httparchive.lighthouse.2020_09_01_mobile` as lh6
                        join
                            `httparchive.lighthouse.2019_07_01_mobile` as lh5 using(url)
                    )
            )
        group by direction, magnitude
    )
