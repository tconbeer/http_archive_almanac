# standardSQL
select perf_score_delta, count(0) as pages
from
    (
        select
            perf_score_lh6 - perf_score_lh5 as perf_score_delta,
            row_number() over (
                order by (perf_score_lh6 - perf_score_lh5)
            ) as row_number,
            count(0) over () as n
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
                join `httparchive.lighthouse.2019_07_01_mobile` as lh5 using (url)
            )
    )
where perf_score_delta is not null
group by perf_score_delta
order by perf_score_delta
