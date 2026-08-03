# standardSQL
# Number of third-parties per websites by rank and category
with
    requests as (
        select _table_suffix as client, pageid as page, url
        from `httparchive.summary_requests.2021_07_01_*`
    ),

    pages as (
        select _table_suffix as client, pageid as page, rank
        from `httparchive.summary_pages.2021_07_01_*`
    ),

    third_party as (
        select domain, canonicaldomain, category, count(distinct page) as page_usage
        from `httparchive.almanac.third_parties` tp
        join requests r on net.host(r.url) = net.host(tp.domain)
        where date = '2021-07-01' and category not in ('hosting')
        group by domain, canonicaldomain, category
        having page_usage >= 50
    ),

    base as (
        select
            client,
            category,
            page,
            rank,
            count(canonicaldomain) as third_parties_per_page
        from requests
        left join third_party on net.host(requests.url) = net.host(third_party.domain)
        inner join pages using (client, page)
        group by client, category, page, rank
    )

select
    client,
    category,
    rank_grouping,
    approx_quantiles(third_parties_per_page, 1000)[
        offset(500)
    ] as p50_third_parties_per_page
from base, unnest([1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
where rank <= rank_grouping
group by client, category, rank_grouping
order by client, category, rank_grouping
