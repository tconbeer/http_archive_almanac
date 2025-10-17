# standardSQL
# Average percentage of resources loaded over HTTP .9, 1, 1.1, 2, and QUIC per site
select
    client,
    avg(http09_pct) as http09_pct,
    avg(http10_pct) as http10_pct,
    avg(http11_pct) as http11_pct,
    avg(http2_pct) as http2_pct,
    avg(quic_pct) as quic_pct,
    avg(http2quic46_pct) as http2quic46_pct,
    avg(other_pct) as other_pct,
    avg(null_pct) as null_pct
from
    (
        select
            client,
            page,
            countif(json_extract_scalar(payload, '$._protocol') = 'http/0.9')
            / count(0) as http09_pct,
            countif(json_extract_scalar(payload, '$._protocol') = 'http/1.0')
            / count(0) as http10_pct,
            countif(json_extract_scalar(payload, '$._protocol') = 'http/1.1')
            / count(0) as http11_pct,
            countif(json_extract_scalar(payload, '$._protocol') = 'HTTP/2')
            / count(0) as http2_pct,
            countif(json_extract_scalar(payload, '$._protocol') = 'QUIC')
            / count(0) as quic_pct,
            countif(json_extract_scalar(payload, '$._protocol') = 'http/2+quic/46')
            / count(0) as http2quic46_pct,
            countif(
                json_extract_scalar(payload, '$._protocol') not in (
                    'http/0.9',
                    'http/1.0',
                    'http/1.1',
                    'HTTP/2',
                    'QUIC',
                    'http/2+quic/46'
                )
            )
            / count(0) as other_pct,
            countif(json_extract_scalar(payload, '$._protocol') is null)
            / count(0) as null_pct
        from `httparchive.almanac.requests`
        where date = '2020-08-01'
        group by client, page
    )
group by client
order by client
