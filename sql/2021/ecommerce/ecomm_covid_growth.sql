# standardSQL
# 13_03: Timeseries to show eCommerce growth acceleration due to Covid-19
# Excluding apps which are not eCommerce platforms/vendors themselves but are used to
# identify eCommerce sites. These are signals added in Wappalyzer in 2020 to get
# better idea on % of eCommerce sites but these are not relevant for vendor % market
# share analysis
select
    if(ends_with(_table_suffix, '_desktop'), 'desktop', 'mobile') as client,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct,
    2021 as year,
    left(_table_suffix, 2) as month
from `httparchive.technologies.2021_*`
join
    (
        select _table_suffix, count(distinct url) as total
        from `httparchive.summary_pages.2021_*`
        group by _table_suffix
    )
    using(_table_suffix)
where category = 'Ecommerce'
group by client, year, month, total

union all

select
    if(ends_with(_table_suffix, '_desktop'), 'desktop', 'mobile') as client,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct,
    2020 as year,
    left(_table_suffix, 2) as month
from `httparchive.technologies.2020_*`
join
    (
        select _table_suffix, count(distinct url) as total
        from `httparchive.summary_pages.2020_*`
        group by _table_suffix
    )
    using(_table_suffix)
where category = 'Ecommerce'
group by client, year, month, total

order by year desc, month desc
