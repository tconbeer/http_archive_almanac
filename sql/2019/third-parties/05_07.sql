# standardSQL
# Top 100 third party domains by total byte weight
select
    thirdpartydomain,
    count(0) as totalrequests,
    sum(requestbytes) as totalbytes,
    round(sum(requestbytes) * 100 / max(totalrequestbytes), 2) as percentbytes
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
        select sum(respsize) as totalrequestbytes
        from `httparchive.almanac.summary_requests`
        where date = '2019-07-01'
    )
where thirdpartydomain is not null
group by thirdpartydomain
order by totalbytes desc
limit 100
