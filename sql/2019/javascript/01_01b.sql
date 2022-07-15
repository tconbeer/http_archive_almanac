# standardSQL
# 01_01b: Distribution of JS bytes by client
select
    percentile,
    _table_suffix as client,
    approx_quantiles(
        round(bytesjs / 1024, 2), 1000) [offset (percentile * 10)
    ] as js_kbytes
from
    `httparchive.summary_pages.2019_07_01_*`,
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
