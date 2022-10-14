# standardSQL
# 07_01: FCP distribution
select fast, avg, slow
from
    (
        select
            round(fast_fcp * 100, 2) as fast,
            round(avg_fcp * 100, 2) as avg,
            round(slow_fcp * 100, 2) as slow,
            row_number() over (order by fast_fcp desc) as row,
            count(0) over () as n
        from `chrome-ux-report.materialized.metrics_summary`
        where date = '2019-07-01' and fast_fcp + avg_fcp + slow_fcp > 0
        order by fast desc
    )
where mod(row, cast(floor(n / 1000) as int64)) = 0
