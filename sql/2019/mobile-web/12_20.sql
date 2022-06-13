# standardSQL
# 12_20: Cumulative layout shift distribution
select * except (row)
from
    (
        select
            row_number() over () as row,
            round(
                safe_divide(small_cls, small_cls + medium_cls + large_cls) * 100, 2
            ) as small_cls,
            round(
                safe_divide(medium_cls, small_cls + medium_cls + large_cls) * 100, 2
            ) as medium_cls,
            round(
                safe_divide(large_cls, small_cls + medium_cls + large_cls) * 100, 2
            ) as large_cls
        from `chrome-ux-report.materialized.device_summary`
        where device = 'phone' and yyyymm = '201907'
        order by small_cls desc
    )
where mod(row, 5229) = 0
