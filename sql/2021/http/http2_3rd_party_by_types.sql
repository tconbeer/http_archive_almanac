# standardSQL
# HTTP/2 3rd Party by Types
select
    percentile,
    client,
    category,
    approx_quantiles(http2_3_pct, 1000) [offset (percentile * 10)] as http2_3_pct
from
    (
        select
            client,
            page,
            category,
            countif(
                lower(http_version) in ('http/2', 'http/3', 'quic', 'h3-29', 'h3-q050')
            )
            / count(0) as http2_3_pct
        from
            (
                select client, page, url, category, protocol as http_version
                from
                    `httparchive.almanac.requests` r,
                    `httparchive.almanac.third_parties` tp
                where
                    r.date = '2021-07-01'
                    and tp.date = '2021-07-01'
                    and net.host(url) = domain
            )
        group by client, page, category
    ),
    unnest( [5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 100]) as percentile
group by percentile, client, category
order by percentile, client, category
