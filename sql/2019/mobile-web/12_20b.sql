# standardSQL
# 12_20b: Sites with majority of CLS >=medium, >=large
select
    count(0) as total_sites,
    countif((perc_medium_cls + perc_large_cls) >= 50) as total_majority_medium_cls,
    countif(perc_large_cls >= 50) as total_majority_large_cls,
    round(
        countif((perc_medium_cls + perc_large_cls) >= 50) * 100 / count(0), 2
    ) as perc_majority_medium_cls,
    round(countif(perc_large_cls >= 50) * 100 / count(0), 2) as perc_majority_large_cls
from
    (
        select
            origin,
            round(
                safe_divide(large_cls, small_cls + medium_cls + large_cls) * 100, 2
            ) as perc_large_cls,
            round(
                safe_divide(medium_cls, small_cls + medium_cls + large_cls) * 100, 2
            ) as perc_medium_cls
        from `chrome-ux-report.materialized.device_summary`
        where device = 'phone' and yyyymm = '201907'
    )
