# standardSQL
# HTTP/2 3rd Party by Types
select
    percentile,
    client,
    category,
    round(approx_quantiles(http2_pct, 1000) [offset (percentile * 10)], 2) as http2_pct
from
    (
        select
            client,
            page,
            category,
            countif(http_version in ('HTTP/2', 'QUIC', 'http/2+quic/46')) / count(
                0
            ) as http2_pct
        from
            (
                select
                    client,
                    page,
                    url,
                    category,
                    json_extract_scalar(payload, '$._protocol') as http_version
                from
                    `httparchive.almanac.requests` r,
                    `httparchive.almanac.third_parties` tp
                where
                    r.date = '2020-08-01' and tp.date = '2020-08-01' and net.host(
                        url
                    ) = domain
            )
        group by client, page, category
    ),
    unnest( [5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 100]) as percentile
group by percentile, client, category
order by percentile, client, category
