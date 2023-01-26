# standardSQL
# Percent of third party requests by content type.
with
    requests as (
        select _table_suffix as client, pageid as page, url, type as contenttype
        from `httparchive.summary_requests.2021_07_01_*`
    ),

    third_party as (
        select domain, category, count(distinct page) as page_usage
        from `httparchive.almanac.third_parties` tp
        join requests r on net.host(r.url) = net.host(tp.domain)
        where date = '2021-07-01' and category != 'hosting'
        group by domain, category
        having page_usage >= 50
    )

select
    client,
    contenttype,
    count(0) as requests,
    sum(count(0)) over (partition by client) as total_requests,
    count(0) / sum(count(0)) over (partition by client) as pct_requests
from requests
left join third_party on net.host(requests.url) = net.host(third_party.domain)
where domain is not null
group by client, contenttype
order by client, contenttype
