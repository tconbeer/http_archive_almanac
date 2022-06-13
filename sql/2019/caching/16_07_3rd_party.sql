# standardSQL
# 16_07_3rd_party: Set-Cookie on cacheable responses by party
select
    client,
    party,
    type,
    uses_cookies,
    sum(count(0)) over (partition by client, party) as all_requests,
    sum(count(distinct pageid)) over (partition by client, party) as all_pages,

    sum(count(0)) over (partition by client, type, party) as total_of_type,
    count(0) as total,
    count(distinct pageid) as pages_using_cookies,

    round(
        count(0) * 100 / sum(count(0)) over (partition by client, type, party), 2
    ) as pct_of_type,
    round(
        count(0) * 100 / sum(count(0)) over (partition by client, party), 2
    ) as pct_of_all_requests,
    round(
        count(distinct pageid) * 100 / sum(
            count(distinct pageid)
        ) over (partition by client, party),
        2
    ) as pct_of_all_pages
from
    (
        select
            client,
            pageid,
            requestid,
            type,
            if(
                strpos(
                    net.host(url), regexp_extract(net.reg_domain(page), r'([\w-]+)')
                ) > 0,
                1,
                3
            ) as party
        from `httparchive.almanac.summary_requests`
    )
join
    (
        select requestid, reqcookielen > 0 as uses_cookies
        from `httparchive.almanac.summary_requests`
        where date = '2019-07-01'
    )
    using(requestid)
where date = '2019-07-01'
group by client, type, uses_cookies, party
order by uses_cookies desc, pct_of_all_pages desc, client, party
