# standardSQL
# 10_15a: % of websites classified as fast/avg/slow
select
    round(countif(fast_fcp >= .9 and fast_fid >= .95) * 100 / count(0), 2) as pct_fast,
    round(
        countif(
            not (slow_fcp >= .1 or slow_fid >= 0.05)
            and not (fast_fcp >= .9 and fast_fid >= .95)
        )
        * 100 / count(
            0
        ),
        2
    ) as pct_avg,
    round(countif(slow_fcp >= .1 or slow_fid >= 0.05) * 100 / count(0), 2) as pct_slow
from `chrome-ux-report.materialized.metrics_summary`
where date = '2019-07-01'
