# standardSQL
# Percentage of total bytes that are from third party requests broken down by third
# party category by resource type.
select
    client,
    thirdpartycategory,
    contenttype,
    sum(requestbytes) as totalbytes,
    round(sum(requestbytes) * 100 / sum(sum(requestbytes)) over (), 4) as percentbytes
from
    (
        select
            client,
            type as contenttype,
            respbodysize as requestbytes,
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
order by percentbytes desc
