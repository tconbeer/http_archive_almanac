# standardSQL
# Percentile breakdown page-relative percentage of requests that are third party
# requests broken down by third party category.
select
    client,
    count(0) as numberofpages,
    countif(numberofthirdpartyrequests > 0) as numberofpageswiththirdparty,
    approx_quantiles(
        numberofthirdpartyrequests / numberofrequests, 100
    ) as percentthirdpartyrequestsquantiles,
    approx_quantiles(
        numberofadrequests / numberofrequests, 100
    ) as percentadrequestsquantiles,
    approx_quantiles(
        numberofanalyticsrequests / numberofrequests, 100
    ) as percentanalyticsrequestsquantiles,
    approx_quantiles(
        numberofsocialrequests / numberofrequests, 100
    ) as percentsocialrequestsquantiles,
    approx_quantiles(
        numberofvideorequests / numberofrequests, 100
    ) as percentvideorequestsquantiles,
    approx_quantiles(
        numberofutilityrequests / numberofrequests, 100
    ) as percentutilityrequestsquantiles,
    approx_quantiles(
        numberofhostingrequests / numberofrequests, 100
    ) as percenthostingrequestsquantiles,
    approx_quantiles(
        numberofmarketingrequests / numberofrequests, 100
    ) as percentmarketingrequestsquantiles,
    approx_quantiles(
        numberofcustomersuccessrequests / numberofrequests, 100
    ) as percentcustomersuccessrequestsquantiles,
    approx_quantiles(
        numberofcontentrequests / numberofrequests, 100
    ) as percentcontentrequestsquantiles,
    approx_quantiles(
        numberofcdnrequests / numberofrequests, 100
    ) as percentcdnrequestsquantiles,
    approx_quantiles(
        numberoftagmanagerrequests / numberofrequests, 100
    ) as percenttagmanagerrequestsquantiles,
    approx_quantiles(
        numberofotherrequests / numberofrequests, 100
    ) as percentotherrequestsquantiles
from
    (
        select
            client,
            pageurl,
            count(0) as numberofrequests,
            countif(thirdpartydomain is null) as numberoffirstpartyrequests,
            countif(thirdpartydomain is not null) as numberofthirdpartyrequests,
            countif(thirdpartycategory = 'ad') as numberofadrequests,
            countif(thirdpartycategory = 'analytics') as numberofanalyticsrequests,
            countif(thirdpartycategory = 'social') as numberofsocialrequests,
            countif(thirdpartycategory = 'video') as numberofvideorequests,
            countif(thirdpartycategory = 'utility') as numberofutilityrequests,
            countif(thirdpartycategory = 'hosting') as numberofhostingrequests,
            countif(thirdpartycategory = 'marketing') as numberofmarketingrequests,
            countif(
                thirdpartycategory = 'customer-success'
            ) as numberofcustomersuccessrequests,
            countif(thirdpartycategory = 'content') as numberofcontentrequests,
            countif(thirdpartycategory = 'cdn') as numberofcdnrequests,
            countif(thirdpartycategory = 'tag-manager') as numberoftagmanagerrequests,
            countif(
                thirdpartycategory = 'other' or thirdpartycategory is null
            ) as numberofotherrequests
        from
            (
                select
                    client,
                    page as pageurl,
                    domainsover50table.requestdomain as thirdpartydomain,
                    thirdpartytable.category as thirdpartycategory
                from `httparchive.almanac.summary_requests`
                left join
                    `lighthouse-infrastructure.third_party_web.2019_07_01`
                    as thirdpartytable
                    on net.host(url) = thirdpartytable.domain
                left join
                    `lighthouse-infrastructure.third_party_web.2019_07_01_all_observed_domains`
                    as domainsover50table
                    on net.host(url) = domainsover50table.requestdomain
                where date = '2019-07-01'
            )
        group by client, pageurl
    )
group by client
