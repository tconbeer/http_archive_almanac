# standardSQL
# Percentile breakdown page-relative percentage of total bytes that are from third
# party requests broken down by third party category.
select
    client,
    count(0) as numberofpages,
    approx_quantiles(
        numberofthirdpartybytes / numberofbytes, 100
    ) as percentthirdpartybytesquantiles,
    approx_quantiles(numberofadbytes / numberofbytes, 100) as percentadbytesquantiles,
    approx_quantiles(
        numberofanalyticsbytes / numberofbytes, 100
    ) as percentanalyticsbytesquantiles,
    approx_quantiles(
        numberofsocialbytes / numberofbytes, 100
    ) as percentsocialbytesquantiles,
    approx_quantiles(
        numberofvideobytes / numberofbytes, 100
    ) as percentvideobytesquantiles,
    approx_quantiles(
        numberofutilitybytes / numberofbytes, 100
    ) as percentutilitybytesquantiles,
    approx_quantiles(
        numberofhostingbytes / numberofbytes, 100
    ) as percenthostingbytesquantiles,
    approx_quantiles(
        numberofmarketingbytes / numberofbytes, 100
    ) as percentmarketingbytesquantiles,
    approx_quantiles(
        numberofcustomersuccessbytes / numberofbytes, 100
    ) as percentcustomersuccessbytesquantiles,
    approx_quantiles(
        numberofcontentbytes / numberofbytes, 100
    ) as percentcontentbytesquantiles,
    approx_quantiles(numberofcdnbytes / numberofbytes, 100) as percentcdnbytesquantiles,
    approx_quantiles(
        numberoftagmanagerbytes / numberofbytes, 100
    ) as percenttagmanagerbytesquantiles,
    approx_quantiles(
        numberofotherbytes / numberofbytes, 100
    ) as percentotherbytesquantiles
from
    (
        select
            client,
            pageurl,
            count(0) as numberofrequests,
            sum(requestbytes) as numberofbytes,
            sum(
                if(thirdpartydomain is null, requestbytes, 0)
            ) as numberoffirstpartybytes,
            sum(
                if(thirdpartydomain is not null, requestbytes, 0)
            ) as numberofthirdpartybytes,
            sum(if(thirdpartycategory = 'ad', requestbytes, 0)) as numberofadbytes,
            sum(
                if(thirdpartycategory = 'analytics', requestbytes, 0)
            ) as numberofanalyticsbytes,
            sum(
                if(thirdpartycategory = 'social', requestbytes, 0)
            ) as numberofsocialbytes,
            sum(
                if(thirdpartycategory = 'video', requestbytes, 0)
            ) as numberofvideobytes,
            sum(
                if(thirdpartycategory = 'utility', requestbytes, 0)
            ) as numberofutilitybytes,
            sum(
                if(thirdpartycategory = 'hosting', requestbytes, 0)
            ) as numberofhostingbytes,
            sum(
                if(thirdpartycategory = 'marketing', requestbytes, 0)
            ) as numberofmarketingbytes,
            sum(
                if(thirdpartycategory = 'customer-success', requestbytes, 0)
            ) as numberofcustomersuccessbytes,
            sum(
                if(thirdpartycategory = 'content', requestbytes, 0)
            ) as numberofcontentbytes,
            sum(if(thirdpartycategory = 'cdn', requestbytes, 0)) as numberofcdnbytes,
            sum(
                if(thirdpartycategory = 'tag-manager', requestbytes, 0)
            ) as numberoftagmanagerbytes,
            sum(
                if(
                    thirdpartycategory = 'other' or thirdpartycategory is null,
                    requestbytes,
                    0
                )
            ) as numberofotherbytes
        from
            (
                select
                    client,
                    page as pageurl,
                    respbodysize as requestbytes,
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
