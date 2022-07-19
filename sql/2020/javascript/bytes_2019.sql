# standardSQL
# Sum of JS request bytes per page (2019)
select
    percentile,
    _table_suffix as client,
    approx_quantiles(bytesjs / 1024, 1000)[offset(percentile * 10)] as js_kilobytes
from
    `httparchive.summary_pages.2019_07_01_*`,
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
