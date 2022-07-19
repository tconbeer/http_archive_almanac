# standardSQL
# 16_10_3rd_party: Use of other Cache-Control directives (e.g., public, private,
# immutable) by party
select
    client,
    party,
    all_requests,
    total_using_control,
    directive,
    count(0) as occurrences,
    round(count(0) * 100 / total_using_control, 2) as pct_of_control,
    round(count(0) * 100 / all_requests, 2) as pct_all_requests
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
            resp_cache_control
        from `httparchive.almanac.requests`
        where date = '2019-07-01'
    ),
    unnest(
        regexp_extract_all(lower(resp_cache_control), r'([a-z][^,\s="\']*)')
    ) as directive
join
    (
        select
            client,
            if(
                strpos(net.host(url), regexp_extract(net.reg_domain(page), r'([\w-]+)'))
                > 0,
                1,
                3
            ) as party,
            count(0) as all_requests,
            countif(trim(resp_cache_control) != '') as total_using_control
        from `httparchive.almanac.requests`
        where date = '2019-07-01'
        group by client, party
    )
    using(client, party)
group by client, all_requests, total_using_control, directive, party
order by occurrences desc
