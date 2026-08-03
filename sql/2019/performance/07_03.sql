# standardSQL
# 07_03: % fast FCP per PSI
select
    round(countif(fast_fcp >= .75) * 100 / count(0), 2) as pct_fast_fcp,
    round(
        countif(not (slow_fcp >= .25) and not (fast_fcp >= .75)) * 100 / count(0), 2
    ) as pct_avg_fcp,
    round(countif(slow_fcp >= .25) * 100 / count(0), 2) as pct_slow_fcp
from `chrome-ux-report.materialized.metrics_summary`
where date = '2019-07-01'
