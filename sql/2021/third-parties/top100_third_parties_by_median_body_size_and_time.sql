# standardSQL
# Top 100 third parties by median response body size, time
with
    requests as (
        select
            _table_suffix as client,
            url,
            pageid as page,
            respbodysize as body_size,
            time
        from `httparchive.summary_requests.2021_07_01_*`
    ),

    third_party as (
        select domain, category, canonicaldomain, count(distinct page) as page_usage
        from `httparchive.almanac.third_parties` tp
        join requests r on net.host(r.url) = net.host(tp.domain)
        where date = '2021-07-01' and category != 'hosting'
        group by domain, canonicaldomain, category
        having page_usage >= 50
    ),

    base as (
        select
            client,
            category,
            canonicaldomain,
            approx_quantiles(body_size, 1000) [offset (500)]
            / 1024 as median_body_size_kb,
            -- noqa: L010
            approx_quantiles(time, 1000) [offset (500)] / 1000 as median_time_s
        from requests
        inner join third_party on net.host(requests.url) = net.host(third_party.domain)
        group by client, category, canonicaldomain
    )

select ranking, client, category, canonicaldomain, metric, sorted_order
from
    (
        select
            'median_body_size_kb' as ranking,
            client,
            category,
            canonicaldomain,
            median_body_size_kb as metric,
            dense_rank() over (
                partition by client order by median_body_size_kb desc
            ) as sorted_order
        from base
        union all
        (
            select
                'median_time_s' as ranking,
                client,
                category,
                canonicaldomain,
                median_time_s as metric,
                dense_rank() over (
                    partition by client order by median_time_s desc
                ) as sorted_order
            from base
        )
    )
where sorted_order <= 100
order by ranking, client, metric desc
