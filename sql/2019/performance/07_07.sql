# standardSQL
# 07_07: TTFB distribution
select fast, avg, slow
from
    (
        select
            round(fast_ttfb * 100, 2) as fast,
            round(avg_ttfb * 100, 2) as avg,
            round(slow_ttfb * 100, 2) as slow,
            row_number() over (order by fast_ttfb desc) as row,
            count(0) over () as n
        from `chrome-ux-report.materialized.metrics_summary`
        where date = '2019-07-01' and fast_ttfb + avg_ttfb + slow_ttfb > 0
        order by fast desc
    )
where mod(row, cast(floor(n / 1000) as int64)) = 0
