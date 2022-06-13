# standardSQL
# Alt text length
select
    client,

    percentile,
    approx_quantiles(alt_length, 1000) [offset (percentile * 10)] as alt_length
from
    (
        select
            _table_suffix as client, safe_cast(alt_length_string as int64) as alt_length
        from
            `httparchive.pages.2020_08_01_*`,
            unnest(
                json_extract_array(
                    json_extract_scalar(payload, '$._almanac'), '$.images.alt_lengths'
                )
            ) as alt_length_string
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
where alt_length > 0
group by percentile, client
order by percentile, client
