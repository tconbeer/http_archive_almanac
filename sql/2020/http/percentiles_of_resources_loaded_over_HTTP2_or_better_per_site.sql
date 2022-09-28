# standardSQL
# Percentiles of sites that load resources of HTTP/2 or above
select
    client,
    percentile,
    approx_quantiles(round(http2_pct, 2), 1000)[
        offset(percentile * 10)
    ] as http2_or_above
from
    (
        select
            client,
            page,
            countif(
                json_extract_scalar(payload, '$._protocol')
                in ('HTTP/2', 'QUIC', 'http/2+quic/46')
            )
            / count(0) as http2_pct
        from `httparchive.almanac.requests`
        where date = '2020-08-01'
        group by client, page
    ),
    unnest([5, 6, 7, 8, 9, 10, 25, 50, 75, 90, 95, 100]) as percentile
group by client, percentile
order by client, percentile
