# standardSQL
# 10_10: linking - extract <a href> count per page (internal + external + hash)
select
    percentile,
    client,
    approx_quantiles(internal, 1000) [offset (percentile * 10)] as internal,
    approx_quantiles(external, 1000) [offset (percentile * 10)] as external,
    approx_quantiles(_hash, 1000) [offset (percentile * 10)] as _hash
from
    (
        select
            client,
            cast(
                json_extract_scalar(
                    almanac, "$['seo-anchor-elements'].internal"
                ) as int64
            ) as internal,
            cast(
                json_extract_scalar(
                    almanac, "$['seo-anchor-elements'].external"
                ) as int64
            ) as external,
            cast(
                json_extract_scalar(almanac, "$['seo-anchor-elements'].hash") as int64
            ) as _hash
        from
            (
                select
                    _table_suffix as client,
                    json_extract_scalar(payload, '$._almanac') as almanac
                from `httparchive.pages.2019_07_01_*`
            )
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
