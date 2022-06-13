# standardSQL
# 16_13_3rd_party: Use of must-revalidate by party
select
    client,
    party,
    count(0) as total_requests,

    countif(uses_cache_control) as total_using_control,
    countif(uses_revalidate) as total_revalidate,

    round(countif(uses_cache_control) * 100 / count(0), 2) as pct_req_using_control,
    round(
        countif(uses_revalidate) * 100 / countif(uses_cache_control), 2
    ) as pct_control_using_revalidate
from
    (
        select
            client,
            if(
                strpos(
                    net.host(url), regexp_extract(net.reg_domain(page), r'([\w-]+)')
                ) > 0,
                1,
                3
            ) as party,
            trim(resp_cache_control) != '' as uses_cache_control,
            regexp_contains(
                resp_cache_control, r'(?i)(^\s*|,\s*)must-revalidate(\s*,|\s*$)'
            ) as uses_revalidate
        from `httparchive.almanac.requests`
        where date = '2019-07-01'
    )
group by client, party
order by client, party
