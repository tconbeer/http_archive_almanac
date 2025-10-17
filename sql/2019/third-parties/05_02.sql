# standardSQL
# Percentage of pages that include at least one ad resource.
select
    client,
    count(0) as numberofpages,
    countif(numberofadrequests > 0) as numberofpageswithad,
    round(countif(numberofadrequests > 0) * 100 / count(0), 2) as percentofpageswithad
from
    (
        select client, pageurl, countif(thirdpartycategory = 'ad') as numberofadrequests
        from
            (
                select
                    client,
                    page as pageurl,
                    thirdpartytable.category as thirdpartycategory
                from `httparchive.almanac.summary_requests`
                left join
                    `lighthouse-infrastructure.third_party_web.2019_07_01`
                    as thirdpartytable
                    on net.host(url) = thirdpartytable.domain
                where date = '2019-07-01'
            )
        group by client, pageurl
    )
group by client
