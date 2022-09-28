# standardSQL
# HTTP/2 % 1st Party versus 3rd Party by Type
select
    percentile,
    client,
    is_third_party,
    type,
    approx_quantiles(http2_3_pct, 1000)[offset(percentile * 10)] as http2_3_pct
from
    (
        select
            client,
            page,
            is_third_party,
            type,
            countif(
                lower(http_version) in ('http/2', 'http/3', 'quic', 'h3-29', 'h3-q050')
            )
            / count(0) as http2_3_pct
        from
            (
                select
                    client,
                    page,
                    url,
                    type,
                    respsize,
                    protocol as http_version,
                    net.host(url) in (
                        select domain
                        from `httparchive.almanac.third_parties`
                        where date = '2021-07-01'
                    ) as is_third_party
                from `httparchive.almanac.requests`
                where date = '2021-07-01'
            )
        group by client, page, is_third_party, type
    ),
    unnest([5, 10, 20, 30, 40, 50, 60, 70, 90, 95, 100]) as percentile
group by percentile, client, is_third_party, type
order by percentile, client, is_third_party, type
