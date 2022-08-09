# standardSQL
# Percent of third party requests and bytes by category and content type.
with
    requests as (
        select
            _table_suffix as client,
            pageid as page,
            url,
            type as contenttype,
            respbodysize as body_size
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

    base as (
        select client, page, category, contenttype, body_size
        from requests
        inner join third_party on net.host(requests.url) = net.host(third_party.domain)
    ),

    requests_per_page_and_category as (
        select
            client,
            page,
            category,
            contenttype,
            sum(sum(body_size)) over (partition by page) as total_page_size,
            sum(body_size) as body_size,
            sum(count(0)) over (partition by page) as total_page_requests,
            count(0) as requests
        from base
        group by client, page, category, contenttype
    )

select
    client,
    category,
    contenttype,
    sum(requests) as requests,
    safe_divide(
        sum(requests), sum(sum(requests)) over (partition by client, category)
    ) as pct_requests,
    sum(body_size) as body_size,
    safe_divide(
        sum(body_size), sum(sum(body_size)) over (partition by client, category)
    ) as pct_body_size
from requests_per_page_and_category
group by client, category, contenttype
order by client, category, contenttype
