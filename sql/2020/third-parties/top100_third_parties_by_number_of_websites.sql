# standardSQL
# Top 100 third parties by number of websites
with
    requests as (
        select pageid as page, req_host as host
        from `httparchive.summary_requests.2020_08_01_mobile`
    ),

    third_party as (
        select domain, canonicaldomain
        from `httparchive.almanac.third_parties`
        where date = '2020-08-01'
    ),

    base as (
        select
            canonicaldomain,
            count(distinct page) as total_pages,
            count(distinct page) / count(distinct page) over () as pct_pages
        from requests
        left join third_party on net.host(requests.host) = net.host(third_party.domain)
        where canonicaldomain is not null
        group by canonicaldomain
    )


select canonicaldomain, total_pages, pct_pages
from
    (
        select
            canonicaldomain,
            total_pages,
            pct_pages,
            dense_rank() over (partition by client order by total_pages desc) as rank
        from base
    )
where rank <= 100
order by total_pages desc
