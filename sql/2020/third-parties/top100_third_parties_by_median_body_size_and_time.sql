# standardSQL
# Top 100 third parties by median response body size, time
with
    requests as (
        select
            _table_suffix as client, req_host as host, respbodysize as body_size, time
        from `httparchive.summary_requests.2020_08_01_*`
    ),

    third_party as (
        select domain, canonicaldomain, category
        from `httparchive.almanac.third_parties`
        where date = '2020-08-01'
    ),

    base as (
        select
            client,
            category,
            canonicaldomain,
            approx_quantiles(body_size, 1000) [
                offset (500)
            ] / 1024 as median_body_size_kb,
            -- noqa: L010
            approx_quantiles(time, 1000) [offset (500)] / 1000 as median_time_s
        from requests
        inner join third_party on net.host(requests.host) = net.host(third_party.domain)
        group by client, category, canonicaldomain
    )

select ranking, client, category, canonicaldomain, metric, rank
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
            ) as rank
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
                ) as rank
            from base
        )
    )
where rank <= 100
order by ranking, client, metric desc
