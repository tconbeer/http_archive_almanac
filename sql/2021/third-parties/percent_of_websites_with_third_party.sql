# standardSQL
# Percent of websites with third parties
with
    requests as (
        select _table_suffix as client, pageid as page, url
        from `httparchive.summary_requests.2021_07_01_*`
    ),

    third_party as (
        select
            domain,
            category,
            count(distinct page) as page_usage,
            count(0) as request_usage
        from `httparchive.almanac.third_parties` tp
        join requests r on net.host(r.url) = net.host(tp.domain)
        where date = '2021-07-01' and category != 'hosting'
        group by domain, category
        having page_usage > 50
    )

select
    client,
    count(distinct if(domain is not null, page, null)) as pages_with_third_party,
    count(distinct page) as total_pages,
    count(distinct if(domain is not null, page, null)) / count(
        distinct page
    ) as pct_pages_with_third_party,
    countif(domain is not null) as third_party_requests,
    count(0) as total_requests,
    countif(domain is not null) / count(0) as pct_third_party_requests
from requests
left join third_party on net.host(requests.url) = net.host(third_party.domain)
group by client
