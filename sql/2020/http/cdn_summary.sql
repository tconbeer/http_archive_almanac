# standardSQL
# CDN Sumamry
select
    percentile,
    client,
    firsthtml,
    cdn,
    round(approx_quantiles(http2_pct, 1000) [offset (percentile * 10)], 2) as http2_pct
from
    (
        select
            client,
            page,
            firsthtml,
            cdn,
            countif(http_version in ('HTTP/2', 'QUIC', 'http/2+quic/46'))
            / count(0) as http2_pct
        from
            (
                select
                    client,
                    page,
                    firsthtml,
                    if(
                        ifnull(regexp_extract(_cdn_provider, r'^([^,]*).*'), '') = '',
                        false,
                        true
                    ) as cdn,
                    url,
                    json_extract_scalar(payload, '$._protocol') as http_version
                from `httparchive.almanac.requests`
                where date = '2020-08-01'
            )
        group by client, page, firsthtml, cdn
    ),
    unnest(generate_array(1, 100)) as percentile
group by percentile, client, firsthtml, cdn
order by percentile, client, firsthtml, cdn
