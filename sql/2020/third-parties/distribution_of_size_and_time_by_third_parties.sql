# standardSQL
# Distribution of third party requests size and time by category
with
    requests as (
        select
            _table_suffix as client, req_host as host, respbodysize as body_size, time
        from `httparchive.summary_requests.2020_08_01_*`
    ),

    third_party as (
        select category, domain
        from `httparchive.almanac.third_parties`
        where date = '2020-08-01'
    ),

    base as (
        select client, category, body_size, time
        from requests
        inner join third_party on net.host(requests.host) = net.host(third_party.domain)
    )

select
    category,
    percentile,
    approx_quantiles(body_size, 1000)[offset(percentile * 10)] as body_size,
    approx_quantiles(time, 1000)[offset(percentile * 10)] as time  -- noqa: L010
from base, unnest([10, 25, 50, 75, 90]) as percentile
group by category, percentile
order by category, percentile
