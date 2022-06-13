# standardSQL
# Distribution of response body size by redirected third parties
# HTTP status codes documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
with
    requests as (
        select
            _table_suffix as client, req_host as host, status, respbodysize as body_size
        from `httparchive.summary_requests.2020_08_01_*`
    ),

    third_party as (
        select domain from `httparchive.almanac.third_parties` where date = '2020-08-01'
    ),

    base as (
        select
            client,
            domain,
            if(status between 300 and 399, 1, 0) as redirected,
            body_size
        from requests
        left join third_party on net.host(requests.host) = net.host(third_party.domain)
    )

select
    client,
    percentile,
    approx_quantiles(body_size, 1000) [
        offset (percentile * 10)
    ] as approx_redirect_body_size
from base, unnest( [10, 25, 50, 75, 90]) as percentile
where redirected = 1
group by client, percentile
order by client, percentile
