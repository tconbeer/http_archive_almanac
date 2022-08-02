# standardSQL
# 13_17b: % CMP solutions share on eCommerce origins broken down by device
select
    _table_suffix as client,
    app,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from `httparchive.technologies.2020_08_01_*`
join
    (
        select _table_suffix, url
        from `httparchive.technologies.2020_08_01_*`
        where category = 'Ecommerce'
    ) using (_table_suffix, url)
join
    (
        select _table_suffix, count(distinct url) as total
        from `httparchive.technologies.2020_08_01_*`
        where category = 'Ecommerce'
        group by _table_suffix
    ) using (_table_suffix)
where category = 'Cookie compliance'
group by client, app, total
order by client, pct desc
