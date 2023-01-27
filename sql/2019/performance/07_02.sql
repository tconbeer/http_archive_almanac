# standardSQL
# 07_02: FID distribution
select fast, avg, slow
from
    (
        select
            round(fast_fid * 100, 2) as fast,
            round(avg_fid * 100, 2) as avg,
            round(slow_fid * 100, 2) as slow,
            row_number() over (order by fast_fid desc) as row,
            count(0) over () as n
        from `chrome-ux-report.materialized.metrics_summary`
        where date = '2019-07-01' and fast_fid + avg_fid + slow_fid > 0
        order by fast desc
    )
where mod(row, cast(floor(n / 1000) as int64)) = 0
