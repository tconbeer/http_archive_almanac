# standardSQL
# 07_10: Percentiles of first/last painted hero
select
    percentile,
    client,
    round(
        approx_quantiles(first_painted_hero, 1000)[offset(percentile * 10)] / 1000, 2
    ) as first_painted_hero,
    round(
        approx_quantiles(last_painted_hero, 1000)[offset(percentile * 10)] / 1000, 2
    ) as last_painted_hero
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract(
                    payload, "$['_heroElementTimes.FirstPaintedHero']"
                ) as int64
            ) as first_painted_hero,
            cast(
                json_extract(payload, "$['_heroElementTimes.LastPaintedHero']") as int64
            ) as last_painted_hero
        from `httparchive.pages.2019_07_01_*`
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
