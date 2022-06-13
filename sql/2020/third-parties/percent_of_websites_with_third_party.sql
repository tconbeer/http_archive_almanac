# standardSQL
# Percent of websites with third parties
with
    requests as (
        select _table_suffix as client, pageid as page, req_host as host
        from `httparchive.summary_requests.2020_08_01_*`
    ),

    third_party as (
        select domain from `httparchive.almanac.third_parties` where date = '2020-08-01'
    )

select
    client,
    count(distinct page) as total_pages,
    count(distinct if(domain is not null, page, null)) / count(
        distinct page
    ) as pct_pages_with_third_party
from requests
left join third_party on net.host(requests.host) = net.host(third_party.domain)
group by client
