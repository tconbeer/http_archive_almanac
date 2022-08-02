# standardSQL
# 13_01: Top ecommerce vendors by device
# Excluding apps which are not eCommerce platforms/vendors themselves but are used to
# identify eCommerce sites. These are signals added in Wappalyzer in 2020 to get
# better idea on % of eCommerce sites but these are not relevant for vendor % market
# share analysis
select
    _table_suffix as client,
    app,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from `httparchive.technologies.2020_08_01_*`
join
    (
        select _table_suffix, count(distinct url) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by _table_suffix
    ) using (_table_suffix)
where
    category = 'Ecommerce'
    and (app != 'Cart Functionality' and app != 'Google Analytics Enhanced eCommerce')
group by client, app, total
order by client desc, pct desc
limit 1000
