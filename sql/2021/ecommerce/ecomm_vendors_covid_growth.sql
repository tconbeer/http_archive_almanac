# standardSQL
# 13_04: Timeseries to show eCommerce vendors growth acceleration due to Covid-19
# Excluding apps which are not eCommerce platforms/vendors themselves but are used to
# identify eCommerce sites. These are signals added in Wappalyzer in 2020 to get
# better idea on % of eCommerce sites but these are not relevant for vendor % market
# share analysis
# Limiting to top 5000 records to continue further analysis in Google Sheets. Using
# HAVING clauses based on 'pct' results in missing data for certain months
select
    if(ends_with(_table_suffix, '_desktop'), 'desktop', 'mobile') as client,
    app,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct,
    left(_table_suffix, 4) as year,
    substr(_table_suffix, 6, 2) as month
from `httparchive.technologies.*`
join
    (
        select _table_suffix, count(distinct url) as total
        from `httparchive.summary_pages.*`
        group by _table_suffix
    )
    using(_table_suffix)
where
    category = 'Ecommerce'
    and (app != 'Cart Functionality' and app != 'Google Analytics Enhanced eCommerce')
group by client, app, year, month, total
order by pct desc, client desc, app desc
limit 5000
