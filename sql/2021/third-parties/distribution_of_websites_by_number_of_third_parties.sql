# standardSQL
# Distribution of websites by number of third party
with
    requests as (
        select _table_suffix as client, pageid as page, url
        from `httparchive.summary_requests.2021_07_01_*`
    ),

    third_party as (
        select domain, canonicaldomain, category, count(distinct page) as page_usage
        from `httparchive.almanac.third_parties` tp
        join requests r on net.host(r.url) = net.host(tp.domain)
        where date = '2021-07-01' and category != 'hosting'
        group by domain, canonicaldomain, category
        having page_usage >= 50
    ),

    base as (
        select client, page, count(canonicaldomain) as third_parties_per_page
        from requests
        left join third_party on net.host(requests.url) = net.host(third_party.domain)
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
