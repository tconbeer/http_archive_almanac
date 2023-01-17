# standardSQL
# 07_08b: % fast TTFB by device
select
    device,
    round(countif(fast_ttfb >= .9) * 100 / count(0), 2) as pct_fast_ttfb,
    round(
        countif(not (slow_ttfb >= .1) and not (fast_ttfb >= .9)) * 100 / count(0), 2
    ) as pct_avg_ttfb,
    round(countif(slow_ttfb >= .1) * 100 / count(0), 2) as pct_slow_ttfb
from
    (
        select
            device,
            safe_divide(fast_ttfb, fast_ttfb + avg_ttfb + slow_ttfb) as fast_ttfb,
            safe_divide(avg_ttfb, fast_ttfb + avg_ttfb + slow_ttfb) as avg_ttfb,
            safe_divide(slow_ttfb, fast_ttfb + avg_ttfb + slow_ttfb) as slow_ttfb
        from `chrome-ux-report.materialized.device_summary`
        where
            yyyymm = '201907'
            and fast_ttfb + avg_ttfb + slow_ttfb > 0
            and device in ('desktop', 'phone')
    )
group by device
