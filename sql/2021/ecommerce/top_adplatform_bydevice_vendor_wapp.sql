# standardSQL
# 13_11b: List of AD Platforms used by vendor usage for eComm - solely from Wapp
select
    _table_suffix as client,
    vendor,
    app,
    countif(category = 'Advertising') as adplatfromfreq,
    sum(count(0)) over (partition by vendor) as total,
    countif(category = 'Advertising') / sum(count(0)) over (partition by vendor) as pct
from `httparchive.technologies.2021_07_01_*`
join
    (
        select _table_suffix as client, url, app as vendor
        from `httparchive.technologies.2021_07_01_*`
        where
            category = 'Ecommerce'
            and (
                app != 'Cart Functionality'
                and app != 'Google Analytics Enhanced eCommerce'
            )
    ) using (url)
group by client, vendor, app
having adplatfromfreq > 0
order by total desc, vendor, adplatfromfreq desc
