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
            req_host as host
        from `httparchive.summary_requests.2020_08_01_*`
    ),

    third_party as (
        select domain from `httparchive.almanac.third_parties` where date = '2020-08-01'
    ),

    base as (
        select
            client,
            type,
            if(
                (
                    status in (301, 302, 307, 308, 410) and not regexp_contains(
                        resp_cache_control, r'(?i)private|no-store'
                    ) and not regexp_contains(reqotherheaders, r'Authorization')
                ) or
                (
                    status in (301, 302, 307, 308, 410) or
                    regexp_contains(resp_cache_control, r'public|max-age|s-maxage') or
                    regexp_contains(respotherheaders, r'Expires')
                ),
                1,
                0
            ) as cached
        from requests
        left join third_party on net.host(requests.host) = net.host(third_party.domain)
        where domain is not null
    )

select
    client,
    type,
    count(0) as total_requests,
    sum(cached) / count(0) as pct_cached_requests
from base
group by client, type
