# standardSQL
# 07_03b: % fast FCP per PSI by device
select
    device,
    round(countif(fast_fcp >= .75) * 100 / count(0), 2) as pct_fast_fcp,
    round(
        countif(not (slow_fcp >= .25) and not (fast_fcp >= .75)) * 100 / count(0), 2
    ) as pct_avg_fcp,
    round(countif(slow_fcp >= .25) * 100 / count(0), 2) as pct_slow_fcp
from
    (
        select
            device,
            safe_divide(fast_fcp, fast_fcp + avg_fcp + slow_fcp) as fast_fcp,
            safe_divide(avg_fcp, fast_fcp + avg_fcp + slow_fcp) as avg_fcp,
            safe_divide(slow_fcp, fast_fcp + avg_fcp + slow_fcp) as slow_fcp
        from `chrome-ux-report.materialized.device_summary`
        where yyyymm = '201907' and device in ('desktop', 'phone')
    )
group by device
