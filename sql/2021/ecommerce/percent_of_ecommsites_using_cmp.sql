# standardSQL
# 13_17a: % of eCommerce Sites by CMPs
select
    _table_suffix as client,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from `httparchive.technologies.2021_07_01_*`
join
    (
        select _table_suffix, url
        from `httparchive.technologies.2021_07_01_*`
        where
            category = 'Ecommerce'
            and (
                app != 'Cart Functionality'
                and app != 'Google Analytics Enhanced eCommerce'
            )

    ) using (_table_suffix, url)
join
    (
        select _table_suffix, count(distinct url) as total
        from `httparchive.technologies.2021_07_01_*`
        where
            category = 'Ecommerce'
            and (
                app != 'Cart Functionality'
                and app != 'Google Analytics Enhanced eCommerce'
            )
        group by _table_suffix
    ) using (_table_suffix)
where category = 'Cookie compliance'
group by client, total
