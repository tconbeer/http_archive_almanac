# standardSQL
# HTTP/2 % 1st Party versus 3rd Party by Type
select
    percentile,
    client,
    is_third_party,
    type,
    round(approx_quantiles(http2_pct, 1000) [offset (percentile * 10)], 2) as http2_pct
from
    (
        select
            client,
            page,
            is_third_party,
            type,
            countif(http_version in ('HTTP/2', 'QUIC', 'http/2+quic/46'))
            / count(0) as http2_pct
        from
            (
                select
                    client,
                    page,
                    url,
                    type,
                    respsize,
                    json_extract_scalar(payload, '$._protocol') as http_version,
                    net.host(url) in (
                        select domain
                        from `httparchive.almanac.third_parties`
                        where date = '2020-08-01'
                    ) as is_third_party
                from `httparchive.almanac.requests`
                where date = '2020-08-01'
            )
        group by client, page, is_third_party, type
    ),
    unnest( [5, 10, 20, 30, 40, 50, 60, 70, 90, 95, 100]) as percentile
group by percentile, client, is_third_party, type
order by percentile, client, is_third_party, type
