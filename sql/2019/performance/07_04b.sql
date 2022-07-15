# standardSQL
# 07_04b: % fast FID per PSI by device
select
    device,
    round(countif(fast_fid >= .95) * 100 / count(0), 2) as pct_fast_fid,
    round(
        countif(not (slow_fid >= .05) and not (fast_fid >= .95)) * 100 / count(0), 2
    ) as pct_avg_fid,
    round(countif(slow_fid >= .05) * 100 / count(0), 2) as pct_slow_fid
from
    (
        select
            device,
            safe_divide(fast_fid, fast_fid + avg_fid + slow_fid) as fast_fid,
            safe_divide(avg_fid, fast_fid + avg_fid + slow_fid) as avg_fid,
            safe_divide(slow_fid, fast_fid + avg_fid + slow_fid) as slow_fid
        from `chrome-ux-report.materialized.device_summary`
        where
            yyyymm = '201907'
            and fast_fid + avg_fid + slow_fid > 0
            and device in ('desktop', 'phone')
    )
group by device
