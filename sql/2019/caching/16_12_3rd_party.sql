# standardSQL
# 16_12_3rd_party: Public vs Private by party
select
    client,
    party,
    count(0) as total_requests,

    countif(uses_cache_control) as total_using_control,
    countif(uses_public) as total_public,
    countif(uses_private) as total_private,
    countif(uses_public and uses_private) as total_using_both,

    round(countif(uses_cache_control) * 100 / count(0), 2) as pct_req_using_control,
    round(
        countif(uses_public) * 100 / countif(uses_cache_control), 2
    ) as pct_control_using_public,
    round(
        countif(uses_private) * 100 / countif(uses_cache_control), 2
    ) as pct_control_using_private,
    round(
        countif(uses_public and uses_private) * 100 / countif(uses_cache_control), 2
    ) as pct_control_using_both
from
    (
        select
            client,
            if(
                strpos(net.host(url), regexp_extract(net.reg_domain(page), r'([\w-]+)'))
                > 0,
                1,
                3
            ) as party,
            trim(resp_cache_control) != '' as uses_cache_control,
            regexp_contains(
                resp_cache_control, r'(?i)(^\s*|,\s*)public(\s*,|\s*$)'
            ) as uses_public,
            regexp_contains(
                resp_cache_control, r'(?i)(^\s*|,\s*)private(\s*,|\s*$)'
            ) as uses_private
        from `httparchive.almanac.requests`
        where date = '2019-07-01'
    )
group by client, party
order by client, party
