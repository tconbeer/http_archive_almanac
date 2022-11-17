# standardSQL
# 07_07b: TTFB desktop distribution
select fast, avg, slow
from
    (
        select
            device,
            round(
                safe_divide(fast_ttfb, fast_ttfb + avg_ttfb + slow_ttfb) * 100, 2
            ) as fast,
            round(
                safe_divide(avg_ttfb, fast_ttfb + avg_ttfb + slow_ttfb) * 100, 2
            ) as avg,
            round(
                safe_divide(slow_ttfb, fast_ttfb + avg_ttfb + slow_ttfb) * 100, 2
            ) as slow,
            row_number() over (order by fast_ttfb desc) as row,
            count(0) over () as n
        from `chrome-ux-report.materialized.device_summary`
        where
            yyyymm = '201907'
            and fast_ttfb + avg_ttfb + slow_ttfb > 0
            and device = 'desktop'
        order by fast desc
    )
where mod(row, cast(floor(n / 1000) as int64)) = 0
