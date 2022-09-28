# standardSQL
# 07_03b2: % fast FCP per (new) PSI by device
select
    device,
    round(countif(fast_fcp >= .75) * 100 / count(0), 2) as pct_fast_fcp,
    round(
        countif(not (slow_fcp >= .25) and not (fast_fcp >= .75)) * 100 / count(0), 2
    ) as pct_avg_fcp,
    round(countif(slow_fcp >= .25) * 100 / count(0), 2) as pct_slow_fcp
from
    (
        select
            form_factor.name as device,
            round(
                safe_divide(
                    sum(if(bin.start < 1000, bin.density, 0)), sum(bin.density)
                ),
                4
            ) as fast_fcp,
            round(
                safe_divide(
                    sum(if(bin.start >= 1000 and bin.start < 3000, bin.density, 0)),
                    sum(bin.density)
                ),
                4
            ) as avg_fcp,
            round(
                safe_divide(
                    sum(if(bin.start >= 3000, bin.density, 0)), sum(bin.density)
                ),
                4
            ) as slow_fcp
        from
            `chrome-ux-report.all.201807`,
            unnest(first_contentful_paint.histogram.bin) as bin
        group by origin, device
    )
group by device
order by pct_fast_fcp desc
