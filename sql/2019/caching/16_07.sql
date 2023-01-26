# standardSQL
# 16_07: Set-Cookie on cacheable responses
select
    client,
    uses_cookies,
    sum(count(0)) over (partition by client) as all_requests,
    sum(count(distinct pageid)) over (partition by client) as all_pages,

    type,
    sum(count(0)) over (partition by client, type) as total_of_type,
    count(0) as total,
    count(distinct pageid) as pages_using_cookies,

    round(
        count(0) * 100 / sum(count(0)) over (partition by client, type), 2
    ) as pct_of_type,
    round(
        count(0) * 100 / sum(count(0)) over (partition by client), 2
    ) as pct_of_all_requests,
    round(
        count(distinct pageid)
        * 100
        / sum(count(distinct pageid)) over (partition by client),
        2
    ) as pct_of_all_pages
from `httparchive.almanac.summary_requests`
join
    (
        select requestid, reqcookielen > 0 as uses_cookies
        from `httparchive.almanac.summary_requests`
        where date = '2019-07-01'
    ) using (requestid)
where date = '2019-07-01'
group by client, type, uses_cookies
order by uses_cookies desc, pct_of_all_pages desc
