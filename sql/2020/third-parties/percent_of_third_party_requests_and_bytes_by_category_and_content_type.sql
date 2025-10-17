# standardSQL
# Percent of third party requests and bytes by category and content type.
with
    requests as (
        select
            pageid as page,
            req_host as host,
            type as contenttype,
            respbodysize as body_size
        from `httparchive.summary_requests.2020_08_01_mobile`
    ),

    third_party as (
        select category, domain
        from `httparchive.almanac.third_parties`
        where date = '2020-08-01'
    ),

    base as (
        select page, category, contenttype, body_size
        from requests
        inner join third_party on net.host(requests.host) = net.host(third_party.domain)
    ),

    requests_per_page_and_category as (
        select
            page,
            category,
            contenttype,
            sum(sum(body_size)) over (partition by page) as total_page_size,
            sum(body_size) as body_size,
            sum(count(0)) over (partition by page) as total_page_requests,
            count(0) as requests
        from base
        group by page, category, contenttype
    )

select
    category,
    contenttype,
    sum(requests) as requests,
    avg(requests) as avg_requests_per_page,
    safe_divide(sum(requests), sum(total_page_requests)) as avg_pct_requests_per_page,
    avg(body_size) as avg_body_size_per_page,
    safe_divide(sum(body_size), sum(total_page_size)) as avg_pct_body_size_per_page
from requests_per_page_and_category
group by category, contenttype
order by category, contenttype
