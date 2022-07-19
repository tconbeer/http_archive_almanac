# standardSQL
# Distribution of external stylesheet transfer size (compressed).
select
    percentile,
    _table_suffix as client,
    approx_quantiles(bytescss / 1024, 1000)[
        offset(percentile * 10)
    ] as stylesheet_kbytes
from
    `httparchive.summary_pages.2019_07_01_*`, unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
