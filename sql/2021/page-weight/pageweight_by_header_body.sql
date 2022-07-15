select
    percentile,
    _table_suffix as client,
    approx_quantiles(
        respheaderssize / 1024, 1000) [offset (percentile * 10)
    ] as resp_header_kbytes,
    approx_quantiles(
        respbodysize / 1024, 1000) [offset (percentile * 10)
    ] as resp_body_kbytes
from
    `httparchive.summary_requests.2021_07_01_*`,
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
