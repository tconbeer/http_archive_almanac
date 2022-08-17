# standardSQL
# Percent of third-party requests with security headers
with
    requests as (
        select rtrim(urlshort, '/') as origin, respotherheaders
        from `httparchive.summary_requests.2020_08_01_mobile`
    ),

    third_party as (
        select category, domain
        from `httparchive.almanac.third_parties`
        where date = '2020-08-01'
    ),

    headers as (
        select
            requests.origin as req_origin,
            lower(respotherheaders) as respotherheaders,
            third_party.category as req_category
        from requests
        inner join
            third_party on net.host(requests.origin) = net.host(third_party.domain)
    ),

    base as (
        select
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
    req_category,
    count(0) as total_requests,
    sum(hsts_header) / count(0) as pct_hsts_header_requests,
    sum(x_content_type_options_header)
    / count(0) as pct_x_content_type_options_header_requests,
    sum(x_frame_options_header) / count(0) as pct_x_frame_options_header_requests,
    sum(x_xss_protection_header) / count(0) as pct_x_xss_protection_header_requests
from base
group by req_category
