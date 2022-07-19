# standardSQL
# 13_16a: Web Push adoption stats by eCommerce origins by device
select
    client,
    count(distinct origin) as totalecommorigins,
    countif(notification_permission_accept is not null) as ecommoriginswithwebpush,
    countif(notification_permission_accept is not null) / count(distinct origin) as pct

from `chrome-ux-report.materialized.metrics_summary`
join
    (
        select distinct _table_suffix as client, rtrim(url, '/') as origin
        from `httparchive.technologies.2020_08_01_*`
        where category = 'Ecommerce'
    )
    using
    (origin)
where date in ('2020-08-01')
group by client
order by client
