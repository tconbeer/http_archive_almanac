# standardSQL
# 16_09: Use of Vary (how many dimensions, what headers, etc.)
select
    client,
    all_requests,
    total_with_vary,
    header_name,
    count(0) as occurrences,
    round(count(0) * 100 / total_with_vary, 2) as pct_of_vary,
    round(count(0) * 100 / all_requests, 2) as pct_all_requests
from
    `httparchive.almanac.requests`,
    unnest(regexp_extract_all(lower(resp_vary), r'([a-z][^,\s="\']*)')) as header_name
join
    (
        select
            date,
            client,
            count(0) as all_requests,
            countif(trim(resp_vary) != '') as total_with_vary
        from `httparchive.almanac.requests`
        where date = '2019-07-01'
        group by date, client
    )
    using(date, client)
where date = '2019-07-01'
group by client, all_requests, total_with_vary, header_name
order by occurrences desc
