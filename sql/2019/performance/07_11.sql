# standardSQL
# 07_11: Percentiles of H1 rendering time
select
    percentile,
    client,
    round(
        approx_quantiles(h1_rendered, 1000) [offset (percentile * 10)] / 1000, 2
    ) as h1_rendered
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract(payload, "$['_heroElementTimes.Heading']") as int64
            ) as h1_rendered
        from `httparchive.pages.2019_07_01_*`
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
