# standardSQL
# 10_15b: % of websites classified as fast/avg/slow by form factor
select
    device,
    round(countif(fast_fcp >= .9 and fast_fid >= .95) * 100 / count(0), 2) as pct_fast,
    round(
        countif(
            not (slow_fcp >= .1 or slow_fid >= 0.05) and not (
                fast_fcp >= .9 and fast_fid >= .95
            )
        ) * 100 / count(0),
        2
    ) as pct_avg,
    round(countif(slow_fcp >= .1 or slow_fid >= 0.05) * 100 / count(0), 2) as pct_slow
from
    (
        select
            device,
            safe_divide(fast_fcp, fast_fcp + avg_fcp + slow_fcp) as fast_fcp,
            safe_divide(avg_fcp, fast_fcp + avg_fcp + slow_fcp) as avg_fcp,
            safe_divide(slow_fcp, fast_fcp + avg_fcp + slow_fcp) as slow_fcp,
            safe_divide(fast_fid, fast_fid + avg_fid + slow_fid) as fast_fid,
            safe_divide(avg_fid, fast_fid + avg_fid + slow_fid) as avg_fid,
            safe_divide(slow_fid, fast_fid + avg_fid + slow_fid) as slow_fid
        from `chrome-ux-report.materialized.device_summary`
        where yyyymm = '201907'
    )
where fast_fid is not null
group by device
order by device
