# standardSQL
# 13_07: Distribution of HTML kilobytes per page
select
    _table_suffix as client,
    percentile,
    approx_quantiles(byteshtml, 1000) [offset (percentile * 10)] / 1024 as requests
from `httparchive.summary_pages.2021_07_01_*`
join
    `httparchive.technologies.2021_07_01_*`
    using(_table_suffix, url),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
where
    category = 'Ecommerce'
    and app != 'Cart Functionality'
    and app != 'Google Analytics Enhanced eCommerce'
group by percentile, client
order by percentile, client
