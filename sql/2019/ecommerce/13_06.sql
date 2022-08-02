# standardSQL
# 13_06: Distribution of image stats
select
    percentile,
    _table_suffix as client,
    approx_quantiles(reqimg, 1000)[offset(percentile * 10)] as image_count,
    round(
        approx_quantiles(bytesimg, 1000)[offset(percentile * 10)] / 1024, 2
    ) as image_kbytes
from `httparchive.summary_pages.2019_07_01_*`
join
    `httparchive.technologies.2019_07_01_*` using (_table_suffix, url),
    unnest([10, 25, 50, 75, 90]) as percentile
where category = 'Ecommerce'
group by percentile, client
order by percentile, client
