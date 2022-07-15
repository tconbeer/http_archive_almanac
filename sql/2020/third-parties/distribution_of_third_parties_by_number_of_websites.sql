# standardSQL
# Distribution of third parties by number of websites
with
    requests as (
        select _table_suffix as client, pageid as page, req_host as host
        from `httparchive.summary_requests.2020_08_01_*`
    ),

    third_party as (
        select domain, canonicaldomain
        from `httparchive.almanac.third_parties`
        where date = '2020-08-01'
    ),

    base as (
        select client, canonicaldomain, count(distinct page) as pages_per_third_party
        from requests
        left join third_party on net.host(requests.host) = net.host(third_party.domain)
        where canonicaldomain is not null
        group by client, canonicaldomain
    )

select
    client,
    percentile,
    approx_quantiles(
        pages_per_third_party, 1000) [offset (percentile * 10)
    ] as approx_pages_per_third_party
from base, unnest( [10, 25, 50, 75, 90]) as percentile
group by client, percentile
order by client, percentile
