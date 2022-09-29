# standardSQL
# Distribution of websites by number of third party
with
    requests as (
        select _table_suffix as client, pageid as page, req_host as host
        from `httparchive.summary_requests.2020_08_01_*`
    ),

    third_party as (
        select domain from `httparchive.almanac.third_parties` where date = '2020-08-01'
    ),

    base as (
        select client, page, count(domain) as third_parties_per_page
        from requests
        left join third_party on net.host(requests.host) = net.host(third_party.domain)
        group by client, page
    )

select
    client,
    percentile,
    approx_quantiles(third_parties_per_page, 1000)[
        offset(percentile * 10)
    ] as approx_third_parties_per_page
from base, unnest([10, 25, 50, 75, 90]) as percentile
group by client, percentile
order by client, percentile
