# standardSQL
# summary_pages data grouped by device and percentiles M107
select
    percentile,
    _table_suffix as client,

    approx_quantiles(byteshtml, 1000) [offset (percentile * 10)] as byteshtml

from
    `httparchive.summary_pages.2020_08_01_*`,
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by client
