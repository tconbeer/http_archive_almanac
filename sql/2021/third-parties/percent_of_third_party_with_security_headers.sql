# standardSQL
# Percent of third-party requests with security headers
with
    requests as (
        select
            _table_suffix as client,
            pageid as page,
            url,
            rtrim(urlshort, '/') as origin,
            respotherheaders
        from `httparchive.summary_requests.2021_07_01_*`
    ),

    third_party as (
        select domain, category, count(distinct page) as page_usage
        from `httparchive.almanac.third_parties` tp
        join requests r on net.host(r.url) = net.host(tp.domain)
        where date = '2021-07-01' and category != 'hosting'
        group by domain, category
        having page_usage >= 50
    ),

    headers as (
        select
            client,
            requests.origin as req_origin,
            lower(respotherheaders) as respotherheaders,
            third_party.category as req_category
        from requests
        inner join
            third_party on net.host(requests.origin) = net.host(third_party.domain)
    ),

    base as (
        select
            client,
            req_origin,
            req_category,
            if(
                strpos(respotherheaders, 'strict-transport-security') > 0, 1, 0
            ) as hsts_header,
            if(
                strpos(respotherheaders, 'x-content-type-options') > 0, 1, 0
            ) as x_content_type_options_header,
            if(
                strpos(respotherheaders, 'x-frame-options') > 0, 1, 0
            ) as x_frame_options_header,
            if(
                strpos(respotherheaders, 'x-xss-protection') > 0, 1, 0
            ) as x_xss_protection_header
        from headers
    )

select
    client,
    req_category,
    count(0) as total_requests,
    sum(hsts_header) / count(0) as pct_hsts_header_requests,
    sum(x_content_type_options_header) / count(
        0
    ) as pct_x_content_type_options_header_requests,
    sum(x_frame_options_header) / count(0) as pct_x_frame_options_header_requests,
    sum(x_xss_protection_header) / count(0) as pct_x_xss_protection_header_requests
from base
group by client, req_category
order by client, req_category
