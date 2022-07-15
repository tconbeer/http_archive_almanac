# standardSQL
# Distribution of response body size by redirected third parties
# HTTP status codes documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
with
    requests as (
        select
            _table_suffix as client,
            pageid as page,
            url,
            status,
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
        select
            client,
            domain,
            if(status between 300 and 399, 1, 0) as redirected,
            body_size
        from requests
        left join third_party on net.host(requests.url) = net.host(third_party.domain)
    )

select
    client,
    percentile,
    approx_quantiles(
        body_size, 1000) [offset (percentile * 10)
    ] as approx_redirect_body_size
from base, unnest(generate_array(1, 100)) as percentile
where redirected = 1
group by client, percentile
order by client, percentile
