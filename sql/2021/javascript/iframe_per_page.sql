select
    client,
    percentile,
    approx_quantiles(iframe_total, 1000) [offset (percentile * 10)] as iframe_total
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract(
                    json_extract_scalar(payload, '$._javascript'), '$.iframe'
                ) as int64
            ) as iframe_total
        from `httparchive.pages.2021_07_01_*`
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
where iframe_total > 0
group by percentile, client
order by percentile, client
