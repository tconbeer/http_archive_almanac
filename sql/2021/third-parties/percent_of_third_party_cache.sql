# standardSQL
# Percent of third party requests cached
# Cache-Control documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control#Directives
with
    requests as (
        select
            _table_suffix as client,
            resp_cache_control,
            status,
            respotherheaders,
            reqotherheaders,
            type,
            url,
            pageid as page
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

    base as (
        select
            client,
            type,
            if(
                (
                    status in (301, 302, 307, 308, 410)
                    and not regexp_contains(resp_cache_control, r'(?i)private|no-store')
                    and not regexp_contains(reqotherheaders, r'Authorization')
                )
                or (
                    status in (301, 302, 307, 308, 410)
                    or regexp_contains(resp_cache_control, r'public|max-age|s-maxage')
                    or regexp_contains(respotherheaders, r'Expires')
                ),
                1,
                0
            ) as cached
        from requests
        left join third_party on net.host(requests.url) = net.host(third_party.domain)
        where domain is not null
    )

select
    client,
    type,
    sum(cached) as cached_requests,
    count(0) as total_requests,
    sum(cached) / count(0) as pct_cached_requests
from base
group by client, type
