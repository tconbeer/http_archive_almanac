# standardSQL
# 16_08_3rd_party: Use of Cache-Control: max-age vs. Expires by party
select
    client,
    party,
    count(0) as total_requests,

    countif(uses_max_age) as total_max_age,
    countif(uses_expires) as total_expires,
    countif(uses_max_age and uses_expires) as total_using_both,
    countif(not uses_max_age and not uses_expires) as total_using_neither,

    round(countif(uses_max_age) * 100 / count(0), 2) as pct_max_age,
    round(countif(uses_expires) * 100 / count(0), 2) as pct_expires,
    round(countif(uses_max_age and uses_expires) * 100 / count(0), 2) as pct_uses_both,
    round(
        countif(not uses_max_age and not uses_expires) * 100 / count(0), 2
    ) as pct_uses_neither
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
            trim(resp_expires) != '' as uses_expires,
            regexp_contains(resp_cache_control, r'(?i)max-age\s*=') as uses_max_age
        from `httparchive.almanac.requests`
        where date = '2019-07-01'
    )
group by client, party
order by client, party
