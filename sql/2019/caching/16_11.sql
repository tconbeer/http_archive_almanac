# standardSQL
# 16_02: Resources served without cache
select
    client,
    count(0) as total_requests,
    type,
    party,

    countif(not_cacheable) as total_not_cacheable,
    countif(not not_cacheable and uses_cache) as total_using_cache,
    countif(not not_cacheable and not uses_cache) as total_not_using_cache,

    round(countif(not_cacheable) * 100 / count(0), 2) as perc_not_cacheable,
    round(
        countif(not not_cacheable and uses_cache) * 100 / count(0), 2
    ) as perc_using_cache,
    round(
        countif(not not_cacheable and not uses_cache) * 100 / count(0), 2
    ) as perc_not_using_cache
from
    (
        select
            client,
            type,
            -- - If the request url's host does not contain the domain of the request
            -- page, this is most likely a 3rd party resource
            if(
                strpos(net.host(url), regexp_extract(net.reg_domain(page), r'([\w-]+)'))
                > 0,
                1,
                3
            ) as party,

            regexp_contains(
                resp_cache_control, r'(?i)(no-cache|no-store)'
            ) as not_cacheable,
            expage > 0 as uses_cache
        from `httparchive.almanac.requests`
        where date = '2019-07-01'
    )
group by client, party, type
order by type, client, party
