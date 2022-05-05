# standardSQL
# 07_23: Percentiles of loading CPU time
# where the main thread of the browser was busy
select
    percentile,
    client,
    approx_quantiles(loading_cpu_time, 1000) [offset (100)] as loading_cpu_time
from
    (
        select
            _table_suffix as client,
            (
                cast(ifnull(json_extract(payload, "$['_cpu.ParseHTML']"), '0') as int64)
            ) as loading_cpu_time
        from `httparchive.pages.2019_07_01_*`
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
