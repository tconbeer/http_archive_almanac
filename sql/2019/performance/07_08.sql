# standardSQL
# 07_08: % fast TTFB using FCP-like thresholds
select
    round(countif(fast_ttfb >= .75) * 100 / count(0), 2) as pct_fast_ttfb,
    round(
        countif(not (slow_ttfb >= .25) and not (fast_ttfb >= .75)) * 100 / count(0), 2
    ) as pct_avg_ttfb,
    round(countif(slow_ttfb >= .25) * 100 / count(0), 2) as pct_slow_ttfb
from `chrome-ux-report.materialized.metrics_summary`
where date = '2019-07-01' and fast_ttfb + avg_ttfb + slow_ttfb > 0
