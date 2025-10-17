# standardSQL
# 07_01b: FCP desktop distribution
select fast, avg, slow
from
    (
        select
            device,
            round(
                safe_divide(fast_fcp, fast_fcp + avg_fcp + slow_fcp) * 100, 2
            ) as fast,
            round(safe_divide(avg_fcp, fast_fcp + avg_fcp + slow_fcp) * 100, 2) as avg,
            round(
                safe_divide(slow_fcp, fast_fcp + avg_fcp + slow_fcp) * 100, 2
            ) as slow,
            row_number() over (order by fast_fcp desc) as row,
            count(0) over () as n
        from `chrome-ux-report.materialized.device_summary`
        where
            yyyymm = '201907'
            and fast_fcp + avg_fcp + slow_fcp > 0
            and device = 'desktop'
        order by fast desc
    )
where mod(row, cast(floor(n / 1000) as int64)) = 0
