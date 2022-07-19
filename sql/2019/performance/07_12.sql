# standardSQL
# 07_12: Percentiles of largest image
select
    percentile,
    client,
    round(
        approx_quantiles(largest_image, 1000)[offset(percentile * 10)] / 1000, 2
    ) as largest_image
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract(payload, "$['_heroElementTimes.Image']") as int64
            ) as largest_image
        from `httparchive.pages.2019_07_01_*`
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
