# standardSQL
# Total Noitification Acceptence Rates across all origins
# Note: not weighted by domain popularity nor number of notifications shown
select
    date,
    if(device = 'phone', 'mobile', device) as client,
    sum(notification_permission_accept) / sum(
        notification_permission_accept
        + notification_permission_deny
        + notification_permission_ignore
        + notification_permission_dismiss
    ) as accept,
    sum(notification_permission_deny) / sum(
        notification_permission_accept
        + notification_permission_deny
        + notification_permission_ignore
        + notification_permission_dismiss
    ) as deny,
    sum(notification_permission_ignore) / sum(
        notification_permission_accept
        + notification_permission_deny
        + notification_permission_ignore
        + notification_permission_dismiss
    ) as _ignore,
    sum(notification_permission_dismiss) / sum(
        notification_permission_accept
        + notification_permission_deny
        + notification_permission_ignore
        + notification_permission_dismiss
    ) as dismiss
from `chrome-ux-report.materialized.device_summary`
where
    (
        notification_permission_accept is not null
        or notification_permission_deny is not null
        or notification_permission_ignore is not null
        or notification_permission_dismiss is not null
    )
    and device in ('desktop', 'phone')
group by date, device
order by date desc, device
