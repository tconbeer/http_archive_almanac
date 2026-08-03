# standardSQL
# Percentage of requests that are third party requests broken down by third party
# category by resource type.
select
    client,
    thirdpartycategory,
    contenttype,
    count(0) as totalrequests,
    round(count(0) * 100 / sum(count(0)) over (), 4) as percentrequests
from
    (
        select
            client,
            type as contenttype,
            ifnull(
                thirdpartytable.category,
                if(domainsover50table.requestdomain is null, 'first-party', 'other')
            ) as thirdpartycategory
        from `httparchive.almanac.summary_requests`
        left join
            `lighthouse-infrastructure.third_party_web.2019_07_01` as thirdpartytable
            on net.host(url) = thirdpartytable.domain
        left join
            `lighthouse-infrastructure.third_party_web.2019_07_01_all_observed_domains`
            as domainsover50table
            on net.host(url) = domainsover50table.requestdomain
        where date = '2019-07-01'
    )
group by client, thirdpartycategory, contenttype
