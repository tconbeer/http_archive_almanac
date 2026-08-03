# standardSQL
# 07_04: % fast FID per PSI
select
    round(countif(fast_fid >= .95) * 100 / count(0), 2) as pct_fast_fid,
    round(
        countif(not (slow_fid >= 0.05) and not (fast_fid >= .95)) * 100 / count(0), 2
    ) as pct_avg_fid,
    round(countif(slow_fid >= 0.05) * 100 / count(0), 2) as pct_slow_fid
from `chrome-ux-report.materialized.metrics_summary`
where date = '2019-07-01' and fast_fid + avg_fid + slow_fid > 0
