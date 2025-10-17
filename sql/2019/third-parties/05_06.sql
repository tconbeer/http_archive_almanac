# standardSQL
# Top 100 third party domains by request volume
select
    thirdpartydomain,
    count(0) as totalrequests,
    round(count(0) * 100 / max(totalrequestcount), 4) as percentrequests,
    sum(requestbytes) as totalbytes
from
    (
        select
            respsize as requestbytes,
            net.host(url) as requestdomain,
            domainsover50table.requestdomain as thirdpartydomain
        from `httparchive.almanac.summary_requests`
        left join
            `lighthouse-infrastructure.third_party_web.2019_07_01_all_observed_domains`
            as domainsover50table
            on net.host(url) = domainsover50table.requestdomain
        where date = '2019-07-01'
    ),
    (
        select count(0) as totalrequestcount
        from `httparchive.almanac.summary_requests`
        where date = '2019-07-01'
    )
group by thirdpartydomain
order by totalrequests desc
limit 100
