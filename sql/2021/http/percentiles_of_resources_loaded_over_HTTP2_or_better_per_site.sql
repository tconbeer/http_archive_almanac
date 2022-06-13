# standardSQL
# Percentiles of sites that load resources of HTTP/2 or above
select
    client,
    percentile,
    approx_quantiles(http2_3_pct, 1000) [offset (percentile * 10)] as http2_or_above
from
    (
        select
            client,
            page,
            countif(
                lower(protocol) in ('http/2', 'http/3', 'quic', 'h3-29', 'h3-q050')
            ) / count(0) as http2_3_pct
        from `httparchive.almanac.requests`
        where date = '2021-07-01'
        group by client, page
    ),
    unnest(generate_array(1, 100)) as percentile
group by client, percentile
order by client, percentile
