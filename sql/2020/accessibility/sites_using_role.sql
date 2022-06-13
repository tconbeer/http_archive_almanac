# standardSQL
# Sites using the role attribute
select
    client,
    sum(count(0)) over (partition by client) as total_sites,
    sum(countif(total_role_attributes > 0)) over (
        partition by client
    ) as total_using_role,
    sum(countif(total_role_attributes > 0)) over (
        partition by client
    ) / sum(count(0)) over (partition by client) as pct_using_role,

    percentile,
    approx_quantiles(total_role_attributes, 1000) [
        offset (percentile * 10)
    ] as total_role_usages
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'),
                    '$.nodes_using_role.total'
                ) as int64
            ) as total_role_attributes
        from `httparchive.pages.2020_08_01_*`
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
