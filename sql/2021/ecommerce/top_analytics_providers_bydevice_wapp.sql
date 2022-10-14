# standardSQL
# 13_10b: Top analytics provides on eCommerce Sites by device
select
    _table_suffix as client,
    app,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from `httparchive.technologies.2021_07_01_*`
join
    (
        select _table_suffix, url
        from `httparchive.technologies.2021_07_01_*`
        where category = 'Ecommerce'
    ) using (_table_suffix, url)
join
    (
        select _table_suffix, count(distinct url) as total
        from `httparchive.technologies.2021_07_01_*`
        where category = 'Ecommerce'
        group by _table_suffix
    ) using (_table_suffix)
where category = 'Analytics'
group by client, app, total
order by client desc, pct desc
