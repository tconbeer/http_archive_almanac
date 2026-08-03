# standardSQL
# 13_06: Distribution of image stats for 2021
select
    percentile,
    _table_suffix as client,
    approx_quantiles(reqimg, 1000)[offset(percentile * 10)] as image_count,
    approx_quantiles(bytesimg, 1000)[offset(percentile * 10)] / 1024 as image_kbytes
from `httparchive.summary_pages.2021_07_01_*`
join
    (
        select distinct _table_suffix, url
        from `httparchive.technologies.2021_07_01_*`
        where
            category = 'Ecommerce'
            and (
                app != 'Cart Functionality'
                and app != 'Google Analytics Enhanced eCommerce'
            )
    ) using (_table_suffix, url),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
