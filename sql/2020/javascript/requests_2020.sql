# standardSQL
# Sum of JS requests per page (2020)
select
    percentile,
    _table_suffix as client,
    approx_quantiles(reqjs, 1000)[offset(percentile * 10)] as js_requests
from
    `httparchive.summary_pages.2020_08_01_*`,
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
