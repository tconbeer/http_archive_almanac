# standardSQL
# 07_04c: % fast FID per PSI by ECT
select
    speed,
    round(countif(fast_fid >= .95) * 100 / count(0), 2) as pct_fast_fid,
    round(
        countif(not (slow_fid >= .05) and not (fast_fid >= .95)) * 100 / count(0), 2
    ) as pct_avg_fid,
    round(countif(slow_fid >= .05) * 100 / count(0), 2) as pct_slow_fid
from
    (
        select
            effective_connection_type.name as speed,
            round(
                safe_divide(sum(if(bin.start < 100, bin.density, 0)), sum(bin.density)),
                4
            ) as fast_fid,
            round(
                safe_divide(
                    sum(if(bin.start >= 100 and bin.start < 300, bin.density, 0)),
                    sum(bin.density)
                ),
                4
            ) as avg_fid,
            round(
                safe_divide(
                    sum(if(bin.start >= 300, bin.density, 0)), sum(bin.density)
                ),
                4
            ) as slow_fid
        from
            `chrome-ux-report.all.201907`,
            unnest(experimental.first_input_delay.histogram.bin) as bin
        group by origin, speed
    )
where fast_fid + avg_fid + slow_fid > 0
group by speed
order by pct_fast_fid desc
