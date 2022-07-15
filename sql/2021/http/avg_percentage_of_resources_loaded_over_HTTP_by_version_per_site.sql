# standardSQL
# Median percentage of resources loaded over HTTP 0.9, 1.0, 1.1, 2+ per site
select
    client,
    approx_quantiles(http09_pct, 1000) [offset (50 * 10)] as http09_pct,
    approx_quantiles(http10_pct, 1000) [offset (50 * 10)] as http10_pct,
    approx_quantiles(http11_pct, 1000) [offset (50 * 10)] as http11_pct,
    approx_quantiles(http2_3_pct, 1000) [offset (50 * 10)] as http2_3_pct,
    approx_quantiles(other_pct, 1000) [offset (50 * 10)] as other_pct,
    approx_quantiles(null_pct, 1000) [offset (50 * 10)] as null_pct
from
    (
        select
            client,
            page,
            countif(lower(protocol) = 'http/0.9') / count(0) as http09_pct,
            countif(lower(protocol) = 'http/1.0') / count(0) as http10_pct,
            countif(lower(protocol) = 'http/1.1') / count(0) as http11_pct,
            countif(
                lower(protocol) = 'http/2'
                or lower(protocol) in ('http/3', 'h3-29', 'h3-q050', 'quic')
            )
            / count(0) as http2_3_pct,
            countif(
                lower(protocol) not in (
                    'http/0.9',
                    'http/1.0',
                    'http/1.1',
                    'http/2',
                    'http/3',
                    'quic',
                    'h3-29',
                    'h3-q050'
                )
            )
            / count(0) as other_pct,
            countif(protocol is null) / count(0) as null_pct
        from `httparchive.almanac.requests`
        where date = '2021-07-01'
        group by client, page
    )
group by client
order by client
