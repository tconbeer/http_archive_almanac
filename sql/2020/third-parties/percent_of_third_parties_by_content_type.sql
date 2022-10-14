# standardSQL
# Percent of third party requests by content type.
with
    requests as (
        select _table_suffix as client, req_host as host, type as contenttype
        from `httparchive.summary_requests.2020_08_01_*`
    ),

    third_party as (
        select domain from `httparchive.almanac.third_parties` where date = '2020-08-01'
    ),

    base as (
        select
            client, contenttype, count(0) over (partition by client) as total_requests
        from requests
        left join third_party on net.host(requests.host) = net.host(third_party.domain)
        where domain is not null
    )

select
    client,
    contenttype,
    total_requests,
    count(0) as requests,
    count(0) / total_requests as pct_requests
from base
group by client, contenttype, total_requests
order by client, contenttype
