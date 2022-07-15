# standardSQL
# 07_21: Percentiles of layout CPU time
# corresponding to the time main thread of the browser was busy
select
    percentile,
    client,
    round(
        approx_quantiles(layout_cpu_time, 1000) [offset (percentile * 10)] / 1000, 2
    ) as layout_cpu_time
from
    (
        select
            _table_suffix as client,
            (
                cast(
                    ifnull(
                        json_extract(payload, "$['_cpu.ParseAuthorStyleSheet']"), '0'
                    ) as int64
                ) + cast(
                    ifnull(json_extract(payload, "$['_cpu.Layout']"), '0') as int64
                ) + cast(
                    ifnull(
                        json_extract(payload, "$['_cpu.UpdateLayoutTree']"), '0'
                    ) as int64
                )
            ) as layout_cpu_time
        from `httparchive.pages.2019_07_01_*`
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
