# standardSQL
# 14_13d: Distribution of image stats per CMS
select
    percentile,
    _table_suffix as client,
    app,
    count(distinct url) as pages,
    approx_quantiles(reqimg, 1000) [offset (percentile * 10)] as image_count,
    round(
        approx_quantiles(bytesimg, 1000) [offset (percentile * 10)] / 1024, 2
    ) as image_kbytes
from `httparchive.summary_pages.2019_07_01_*`
join
    `httparchive.technologies.2019_07_01_*`
    using(_table_suffix, url),
    unnest( [10, 25, 50, 75, 90]) as percentile
where category = 'CMS'
group by percentile, client, app
order by percentile, client, pages desc
