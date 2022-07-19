# standardSQL
# Top 100 third parties by number of websites
with
    requests as (
        select _table_suffix as client, pageid as page, url
        from `httparchive.summary_requests.2021_07_01_*`
    ),

    totals as (
        select
            _table_suffix as client,
            count(distinct pageid) as total_pages,
            count(0) as total_requests
        from `httparchive.summary_requests.2021_07_01_*`
        group by _table_suffix
    ),

    third_party as (
        select domain, canonicaldomain, category, count(distinct page) as page_usage
        from `httparchive.almanac.third_parties` tp
        join requests r on net.host(r.url) = net.host(tp.domain)
        where date = '2021-07-01' and category != 'hosting'
        group by domain, canonicaldomain, category
        having page_usage >= 50
    )

select
    client,
    canonicaldomain,
    count(distinct page) as pages,
    total_pages,
    count(distinct page) / total_pages as pct_pages,
    count(0) as requests,
    total_requests,
    count(0) / total_requests as pct_requests,
    dense_rank() over (
        partition by client order by count(distinct page) desc
    ) as sorted_order
from requests
left join third_party on net.host(requests.url) = net.host(third_party.domain)
join totals using(client)
where canonicaldomain is not null
group by client, total_pages, total_requests, canonicaldomain
qualify sorted_order <= 100
order by pct_pages desc, client
