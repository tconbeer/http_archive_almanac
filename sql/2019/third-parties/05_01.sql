# standardSQL
# Percentage of pages that include at least one third party resource.
select
    client,
    count(0) as numberofpages,
    countif(numberofthirdpartyrequests > 0) as numberofpageswiththirdparty,
    round(
        countif(numberofthirdpartyrequests > 0) * 100 / count(0), 2
    ) as percentofpageswiththirdparty
from
    (
        select
            client,
            pageurl,
            countif(thirdpartydomain is not null) as numberofthirdpartyrequests
        from
            (
                select
                    client,
                    page as pageurl,
                    domainsover50table.requestdomain as thirdpartydomain
                from `httparchive.almanac.summary_requests`
                left join
                    `lighthouse-infrastructure.third_party_web.2019_07_01_all_observed_domains`
                    as domainsover50table
                    on net.host(url) = domainsover50table.requestdomain
                where date = '2019-07-01'
            )
        group by client, pageurl
    )
group by client
