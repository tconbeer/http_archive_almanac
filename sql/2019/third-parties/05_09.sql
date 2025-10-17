# standardSQL
# Top 100 third party requests by request volume
select
    requesturl,
    count(0) as totalrequests,
    sum(requestbytes) as totalbytes,
    round(count(0) * 100 / max(t2.totalrequestcount), 2) as percentrequestcount
from
    (
        select url as requesturl, respbodysize as requestbytes
        from `httparchive.almanac.summary_requests`
        where date = '2019-07-01'
    ),
    (
        select count(0) as totalrequestcount
        from `httparchive.almanac.summary_requests`
        where date = '2019-07-01'
    )
group by requesturl
order by totalrequests desc
limit 100
