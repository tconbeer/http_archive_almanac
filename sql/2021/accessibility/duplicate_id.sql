# standardSQL
# Duplicate ID occurrences
select
    client,
    sum(count(0)) over (partition by client) as total_sites,
    sum(countif(total_duplicate_ids > 0)) over (
        partition by client
    ) as total_with_duplicate_ids,
    sum(countif(total_duplicate_ids > 0)) over (partition by client)
    / sum(count(0)) over (partition by client) as pct_with_duplicate_ids,

    percentile,
    approx_quantiles(
        total_duplicate_ids, 1000) [offset (percentile * 10)
    ] as total_duplicate_ids
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._markup'),
                    '$.ids.duplicate_ids_total'
                ) as int64
            ) as total_duplicate_ids
        from `httparchive.pages.2021_07_01_*`
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
