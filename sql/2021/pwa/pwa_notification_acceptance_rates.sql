# standardSQL
# 13_16b: Web Push Notification CRUX stats (10th / 25th / 50th / 75th / 90th / 100th
# percentile) for PWA origins
# Based on
# https://github.com/HTTPArchive/almanac.httparchive.org/blob/main/sql/2020/ecommerce/webpushstats_ecommsites.sql
select
    date,
    client,
    percentile,
    approx_quantiles(notification_permission_accept, 1000 respect nulls)[
        offset(percentile * 10)
    ] as notification_permission_accept,
    approx_quantiles(notification_permission_deny, 1000 respect nulls)[
        offset(percentile * 10)
    ] as notification_permission_deny,
    approx_quantiles(notification_permission_ignore, 1000 respect nulls)[
        offset(percentile * 10)
    ] as notification_permission_ignore,
    approx_quantiles(notification_permission_dismiss, 1000 respect nulls)[
        offset(percentile * 10)
    ] as notification_permission_dismiss
from `chrome-ux-report.materialized.metrics_summary`
join
    (
        select _table_suffix as client, rtrim(url, '/') as origin, count(0) as total
        from `httparchive.pages.2021_07_01_*`
        where json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
        group by _table_suffix, url
    ) using (origin),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
where
    date in ('2021-07-01')
    and (
        notification_permission_accept is not null
        or notification_permission_deny is not null
        or notification_permission_ignore is not null
        or notification_permission_dismiss is not null
    )
group by date, client, percentile
order by date, client, percentile
