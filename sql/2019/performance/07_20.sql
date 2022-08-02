# standardSQL
# 07_20: Percentiles of scripting CPU time
# corresponding to the time main thread of the browser was busy
select
    percentile,
    client,
    round(
        approx_quantiles(script_cpu_time, 1000)[offset(percentile * 10)] / 1000, 2
    ) as script_cpu_time
from
    (
        select
            _table_suffix as client,
            (
                cast(
                    ifnull(
                        json_extract(payload, "$['_cpu.EvaluateScript']"), '0'
                    ) as int64
                ) + cast(
                    ifnull(json_extract(payload, "$['_cpu.XHRLoad']"), '0') as int64
                ) + cast(
                    ifnull(
                        json_extract(payload, "$['_cpu.XHRReadyStateChange']"), '0'
                    ) as int64
                ) + cast(
                    ifnull(json_extract(payload, "$['_cpu.TimerFire']"), '0') as int64
                ) + cast(
                    ifnull(
                        json_extract(payload, "$['_cpu.EventDispatch']"), '0'
                    ) as int64
                ) + cast(
                    ifnull(
                        json_extract(payload, "$['_cpu.FunctionCall']"), '0'
                    ) as int64
                ) + cast(
                    ifnull(json_extract(payload, "$['_cpu.v8.compile']"), '0') as int64
                ) + cast(
                    ifnull(json_extract(payload, "$['_cpu.MinorGC']"), '0') as int64
                ) + cast(
                    ifnull(
                        json_extract(payload, "$['_cpu.FireAnimationFrame']"), '0'
                    ) as int64
                ) + cast(
                    ifnull(json_extract(payload, "$['_cpu.MajorGC']"), '0') as int64
                )
            ) as script_cpu_time
        from `httparchive.pages.2019_07_01_*`
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
