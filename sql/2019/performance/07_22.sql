# standardSQL
# 07_22: Percentiles of paint CPU time
# where the main thread of the browser was busy
select
    percentile,
    client,
    approx_quantiles(paint_cpu_time, 1000) [offset (percentile * 10)] as paint_cpu_time
from
    (
        select
            _table_suffix as client,
            (
                cast(
                    ifnull(json_extract(payload, "$['_cpu.Paint']"), '0') as int64
                ) + cast(
                    ifnull(
                        json_extract(payload, "$['_cpu.UpdateLayerTree']"), '0'
                    ) as int64
                )
            ) as paint_cpu_time
        from `httparchive.pages.2019_07_01_*`
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
