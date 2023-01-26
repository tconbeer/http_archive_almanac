# standardSQL
# Offline origins
select
    total_origins,
    offline_origins,
    offline_origins / total_origins as pct_offline_origins
from
    (
        select
            count(distinct origin) as total_origins,
            count(distinct if(offlinedensity > 0, origin, null)) as offline_origins
        from `chrome-ux-report.materialized.metrics_summary`
        where date = '2020-08-01'
    )
