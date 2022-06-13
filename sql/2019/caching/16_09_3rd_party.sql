# standardSQL
# 16_09_3rd_party: Use of Vary (how many dimensions, what headers, etc.) by party
select
    client,
    party,
    all_requests,
    total_with_vary,
    header_name,
    count(0) as occurrences,
    round(count(0) * 100 / total_with_vary, 2) as pct_of_vary,
    round(count(0) * 100 / all_requests, 2) as pct_all_requests
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
            resp_vary
        from `httparchive.almanac.requests`
        where date = '2019-07-01'
    ),
    unnest(regexp_extract_all(lower(resp_vary), r'([a-z][^,\s="\']*)')) as header_name
join
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
            count(0) as all_requests,
            countif(trim(resp_vary) != '') as total_with_vary
        from `httparchive.almanac.requests`
        where date = '2019-07-01'
        group by client, party
    )
    using(date, client, party)
group by client, all_requests, total_with_vary, header_name, party
order by occurrences desc
