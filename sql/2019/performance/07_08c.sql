# standardSQL
# 07_08c: % fast TTFB by ECT
select
    speed,
    round(countif(fast_ttfb >= .9) * 100 / count(0), 2) as pct_fast_ttfb,
    round(
        countif(not (slow_ttfb >= .1) and not (fast_ttfb >= .9)) * 100 / count(0), 2
    ) as pct_avg_ttfb,
    round(countif(slow_ttfb >= .1) * 100 / count(0), 2) as pct_slow_ttfb
from
    (
        select
            effective_connection_type.name as speed,
            round(
                safe_divide(sum(if(bin.start < 200, bin.density, 0)), sum(bin.density)),
                4
            ) as fast_ttfb,
            round(
                safe_divide(
                    sum(if(bin.start >= 200 and bin.start < 1000, bin.density, 0)),
                    sum(bin.density)
                ),
                4
            ) as avg_ttfb,
            round(
                safe_divide(
                    sum(if(bin.start >= 1000, bin.density, 0)), sum(bin.density)
                ),
                4
            ) as slow_ttfb
        from
            `chrome-ux-report.all.201907`,
            unnest(experimental.time_to_first_byte.histogram.bin) as bin
        group by origin, speed
    )
group by speed
order by pct_fast_ttfb desc
