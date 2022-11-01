# standardSQL
# Percent of third-party requests loaded before DOM Content Loaded event
with
    requests as (
        select
            _table_suffix as client,
            page,
            url,
            safe_cast(json_extract_scalar(payload, '$._load_end') as int64) as load_end
        from `httparchive.requests.2020_08_01_*`
    ),

    pages as (
        select _table_suffix as client, url, oncontentloaded
        from `httparchive.summary_pages.2020_08_01_*`
    ),

    third_party as (
        select category, domain
        from `httparchive.almanac.third_parties`
        where date = '2020-08-01'
    ),

    base as (
        select
            requests.client as client,
            third_party.domain as request_domain,
            if(requests.load_end < pages.oncontentloaded, 1, 0) as early_request,
            third_party.category as request_category
        from requests
        inner join third_party on net.host(requests.url) = net.host(third_party.domain)
        left join pages on requests.page = pages.url and requests.client = pages.client
    )

select
    client,
    request_category,
    count(0) as total_requests,
    sum(early_request) / count(0) as pct_early_requests
from base
group by client, request_category
