# standardSQL
# 16_10: Use of other Cache-Control directives (e.g., public, private, immutable)
select
    client,
    all_requests,
    total_using_control,
    directive,
    count(0) as occurrences,
    round(count(0) * 100 / total_using_control, 2) as pct_of_control,
    round(count(0) * 100 / all_requests, 2) as pct_all_requests
from
    `httparchive.almanac.requests`,
    unnest(
        regexp_extract_all(lower(resp_cache_control), r'([a-z][^,\s="\']*)')
    ) as directive
join
    (
        select
            client,
            count(0) as all_requests,
            countif(trim(resp_cache_control) != '') as total_using_control
        from `httparchive.almanac.requests`
        where date = '2019-07-01'
        group by client
    ) using (client)
where date = '2019-07-01'
group by client, all_requests, total_using_control, directive
order by occurrences desc
