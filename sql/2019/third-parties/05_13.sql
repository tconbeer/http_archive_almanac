# standardSQL
# Percentile breakdown page-relative percentage of total script execution time that is
# from third party requests broken down by third party category.
create temporary function getexecutiontimes(report string)
returns array<struct<url string, execution_time float64>>
language js
as '''
try {
  var $ = JSON.parse(report);
  return $.audits['bootup-time'].details.items.map(item => ({
    url: item.url,
    execution_time: item.scripting
  }));
} catch (e) {
  return [];
}
'''
;

select
    count(0) as numberofpages,
    approx_quantiles(
        amountofthirdpartytime / executiontime, 100
    ) as percentthirdpartytimequantiles,
    approx_quantiles(amountofadtime / executiontime, 100) as percentadtimequantiles,
    approx_quantiles(
        amountofanalyticstime / executiontime, 100
    ) as percentanalyticstimequantiles,
    approx_quantiles(
        amountofsocialtime / executiontime, 100
    ) as percentsocialtimequantiles,
    approx_quantiles(
        amountofvideotime / executiontime, 100
    ) as percentvideotimequantiles,
    approx_quantiles(
        amountofutilitytime / executiontime, 100
    ) as percentutilitytimequantiles,
    approx_quantiles(
        amountofhostingtime / executiontime, 100
    ) as percenthostingtimequantiles,
    approx_quantiles(
        amountofmarketingtime / executiontime, 100
    ) as percentmarketingtimequantiles,
    approx_quantiles(
        amountofcustomersuccesstime / executiontime, 100
    ) as percentcustomersuccesstimequantiles,
    approx_quantiles(
        amountofcontenttime / executiontime, 100
    ) as percentcontenttimequantiles,
    approx_quantiles(amountofcdntime / executiontime, 100) as percentcdntimequantiles,
    approx_quantiles(
        amountoftagmanagertime / executiontime, 100
    ) as percenttagmanagertimequantiles,
    approx_quantiles(
        amountofothertime / executiontime, 100
    ) as percentothertimequantiles
from
    (
        select
            pageurl,
            count(0) as numberofscripts,
            sum(executiontime) as executiontime,
            sum(
                if(thirdpartydomain is null, executiontime, 0)
            ) as amountoffirstpartytime,
            sum(
                if(thirdpartydomain is not null, executiontime, 0)
            ) as amountofthirdpartytime,
            sum(if(thirdpartycategory = 'ad', executiontime, 0)) as amountofadtime,
            sum(
                if(thirdpartycategory = 'analytics', executiontime, 0)
            ) as amountofanalyticstime,
            sum(
                if(thirdpartycategory = 'social', executiontime, 0)
            ) as amountofsocialtime,
            sum(
                if(thirdpartycategory = 'video', executiontime, 0)
            ) as amountofvideotime,
            sum(
                if(thirdpartycategory = 'utility', executiontime, 0)
            ) as amountofutilitytime,
            sum(
                if(thirdpartycategory = 'hosting', executiontime, 0)
            ) as amountofhostingtime,
            sum(
                if(thirdpartycategory = 'marketing', executiontime, 0)
            ) as amountofmarketingtime,
            sum(
                if(thirdpartycategory = 'customer-success', executiontime, 0)
            ) as amountofcustomersuccesstime,
            sum(
                if(thirdpartycategory = 'content', executiontime, 0)
            ) as amountofcontenttime,
            sum(if(thirdpartycategory = 'cdn', executiontime, 0)) as amountofcdntime,
            sum(
                if(thirdpartycategory = 'tag-manager', executiontime, 0)
            ) as amountoftagmanagertime,
            sum(
                if(
                    thirdpartycategory = 'other' or thirdpartycategory is null,
                    executiontime,
                    0
                )
            ) as amountofothertime
        from
            (
                select
                    lh.url as pageurl,
                    item.execution_time as executiontime,
                    domainsover50table.requestdomain as thirdpartydomain,
                    thirdpartytable.category as thirdpartycategory
                from
                    `httparchive.lighthouse.2019_07_01_mobile` as lh,
                    unnest(getexecutiontimes(lh.report)) as item
                left join
                    `lighthouse-infrastructure.third_party_web.2019_07_01`
                    as thirdpartytable
                    on net.host(item.url) = thirdpartytable.domain
                left join
                    `lighthouse-infrastructure.third_party_web.2019_07_01_all_observed_domains`
                    as domainsover50table
                    on net.host(item.url) = domainsover50table.requestdomain
            )
        group by pageurl
    )
