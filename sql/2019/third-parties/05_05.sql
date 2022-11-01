# standardSQL
# Percentage of script execution time that are from third party requests broken down
# by third party category.
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
    ifnull(
        thirdpartytable.category,
        if(domainsover50table.requestdomain is null, 'first-party', 'other')
    ) as third_party_category,
    sum(item.execution_time) as total_execution_time,
    round(
        sum(item.execution_time) * 100 / sum(sum(item.execution_time)) over (), 4
    ) as pct_execution_time
from
    `httparchive.lighthouse.2019_07_01_mobile`,
    unnest(getexecutiontimes(report)) as item
left join
    `lighthouse-infrastructure.third_party_web.2019_07_01` as thirdpartytable
    on net.host(item.url) = thirdpartytable.domain
left join
    `lighthouse-infrastructure.third_party_web.2019_07_01_all_observed_domains`
    as domainsover50table
    on net.host(item.url) = domainsover50table.requestdomain
group by third_party_category
order by pct_execution_time desc
