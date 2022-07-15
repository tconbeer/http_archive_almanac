# standardSQL
# 13_15b: % of CDN usage for eComm - solely from Wapp
select
    _table_suffix as client,
    vendor,
    app,
    countif(category = 'CDN') as cdnplatfromfreq,
    sum(count(0)) over (partition by vendor) as total,
    countif(category = 'CDN') / sum(count(0)) over (partition by vendor) as pct
from `httparchive.technologies.2021_07_01_*`
join
    (
        select _table_suffix as client, url, app as vendor
        from `httparchive.technologies.2021_07_01_*`
        where category = 'Ecommerce'
    )
    using
    (url)
group by client, vendor, app
having cdnplatfromfreq > 0
order by total desc, vendor, cdnplatfromfreq desc
