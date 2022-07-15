# standardSQL
# 13_14: % of AMP enabled eCommerce Sites by device
select
    _table_suffix as client,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from `httparchive.technologies.2020_08_01_*`
join
    (
        select _table_suffix, url
        from `httparchive.technologies.2020_08_01_*`
        where category = 'Ecommerce'
    )
    using
    (_table_suffix, url)
join
    (
        select _table_suffix, count(distinct url) as total
        from `httparchive.technologies.2020_08_01_*`
        where category = 'Ecommerce'
        group by _table_suffix
    )
    using
    (_table_suffix)
where app = 'AMP'
group by client, total
order by client
