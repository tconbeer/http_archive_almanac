# standardSQL
# HTTP/2+ support per CDN by page and request
select
    client,
    cdn,
    countif(firsthtml) as pages,
    countif(http2_3 and firsthtml) as http2_3_pages,
    safe_divide(countif(http2_3 and firsthtml), countif(firsthtml)) as http2_3_page_pct,
    countif(http2_3) as http2_3_requests,
    countif(http2_3) / count(0) as http2_3_request_pct
from
    (
        select
            client,
            page,
            firsthtml,
            ifnull(regexp_extract(_cdn_provider, r'^([^,]*).*'), '') as cdn,
            url,
            lower(protocol)
            in ('http/2', 'http/3', 'quic', 'h3-29', 'h3-q050') as http2_3
        from `httparchive.almanac.requests`
        where date = '2021-07-01'
    )
group by client, cdn
order by http2_3_request_pct desc, client, cdn
