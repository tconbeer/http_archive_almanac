# standardSQL
# 13_16b: Web Push Notification CRUX stats (10th / 25th / 50th / 75th / 90th / 100th
# percentile) for eCommerce origins
select
    date,
    client,

    round(
        approx_quantiles(notification_permission_accept, 1000 respect nulls) [
            offset (100)
        ],
        3
    ) as notification_permission_accept_10th_percentile,
    round(
        approx_quantiles(notification_permission_accept, 1000 respect nulls) [
            offset (250)
        ],
        3
    ) as notification_permission_accept_25th_percentile,
    round(
        approx_quantiles(notification_permission_accept, 1000 respect nulls) [
            offset (500)
        ],
        3
    ) as notification_permission_accept_50th_percentile,
    round(
        approx_quantiles(notification_permission_accept, 1000 respect nulls) [
            offset (750)
        ],
        3
    ) as notification_permission_accept_75th_percentile,
    round(
        approx_quantiles(notification_permission_accept, 1000 respect nulls) [
            offset (900)
        ],
        3
    ) as notification_permission_accept_90th_percentile,
    round(
        approx_quantiles(notification_permission_accept, 1000 respect nulls) [
            offset (1000)
        ],
        3
    ) as notification_permission_accept_100th_percentile,

    round(
        approx_quantiles(notification_permission_deny, 1000 respect nulls) [
            offset (100)
        ],
        3
    ) as notification_permission_deny_10th_percentile,
    round(
        approx_quantiles(notification_permission_deny, 1000 respect nulls) [
            offset (250)
        ],
        3
    ) as notification_permission_deny_25th_percentile,
    round(
        approx_quantiles(notification_permission_deny, 1000 respect nulls) [
            offset (500)
        ],
        3
    ) as notification_permission_deny_50th_percentile,
    round(
        approx_quantiles(notification_permission_deny, 1000 respect nulls) [
            offset (750)
        ],
        3
    ) as notification_permission_deny_75th_percentile,
    round(
        approx_quantiles(notification_permission_deny, 1000 respect nulls) [
            offset (900)
        ],
        3
    ) as notification_permission_deny_90th_percentile,
    round(
        approx_quantiles(notification_permission_deny, 1000 respect nulls) [
            offset (1000)
        ],
        3
    ) as notification_permission_deny_100th_percentile,

    round(
        approx_quantiles(notification_permission_ignore, 1000 respect nulls) [
            offset (100)
        ],
        3
    ) as notification_permission_ignore_10th_percentile,
    round(
        approx_quantiles(notification_permission_ignore, 1000 respect nulls) [
            offset (250)
        ],
        3
    ) as notification_permission_ignore_25th_percentile,
    round(
        approx_quantiles(notification_permission_ignore, 1000 respect nulls) [
            offset (500)
        ],
        3
    ) as notification_permission_ignore_50th_percentile,
    round(
        approx_quantiles(notification_permission_ignore, 1000 respect nulls) [
            offset (750)
        ],
        3
    ) as notification_permission_ignore_75th_percentile,
    round(
        approx_quantiles(notification_permission_ignore, 1000 respect nulls) [
            offset (900)
        ],
        3
    ) as notification_permission_ignore_90th_percentile,
    round(
        approx_quantiles(notification_permission_ignore, 1000 respect nulls) [
            offset (1000)
        ],
        3
    ) as notification_permission_ignore_100th_percentile,

    round(
        approx_quantiles(notification_permission_dismiss, 1000 respect nulls) [
            offset (100)
        ],
        3
    ) as notification_permission_dismiss_10th_percentile,
    round(
        approx_quantiles(notification_permission_dismiss, 1000 respect nulls) [
            offset (250)
        ],
        3
    ) as notification_permission_dismiss_25th_percentile,
    round(
        approx_quantiles(notification_permission_dismiss, 1000 respect nulls) [
            offset (500)
        ],
        3
    ) as notification_permission_dismiss_50th_percentile,
    round(
        approx_quantiles(notification_permission_dismiss, 1000 respect nulls) [
            offset (750)
        ],
        3
    ) as notification_permission_dismiss_75th_percentile,
    round(
        approx_quantiles(notification_permission_dismiss, 1000 respect nulls) [
            offset (900)
        ],
        3
    ) as notification_permission_dismiss_90th_percentile,
    round(
        approx_quantiles(notification_permission_dismiss, 1000 respect nulls) [
            offset (1000)
        ],
        3
    ) as notification_permission_dismis_100th_percentiles

from `chrome-ux-report.materialized.metrics_summary`
join
    (
        select distinct _table_suffix as client, rtrim(url, '/') as origin
        from `httparchive.technologies.2020_08_01_*`
        where category = 'Ecommerce'
    )
    using
    (origin)
where date in ('2020-08-01') and notification_permission_accept is not null
group by date, client
order by date, client
