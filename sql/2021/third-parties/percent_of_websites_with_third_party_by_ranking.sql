# standardSQL
# Percent of websites with third parties by ranking
with
    requests as (
        select _table_suffix as client, pageid as page, url
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

    pages as (
        select _table_suffix as client, pageid as page, rank
        from `httparchive.summary_pages.2021_07_01_*`
    )

select
    client,
    rank_grouping,
    count(distinct if(domain is not null, page, null)) as pages_with_third_party,
    count(distinct page) as total_pages,
    count(distinct if(domain is not null, page, null))
    / count(distinct page) as pct_pages_with_third_party
from pages
join requests using (client, page)
left join
    third_party on net.host(requests.url) = net.host(third_party.domain),
    unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
where rank <= rank_grouping
group by client, rank_grouping
order by client, rank_grouping
