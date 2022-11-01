# standardSQL
# Top 100 third party domains by total script execution time.
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
    thirdpartydomain,
    count(0) as totalscripts,
    sum(executiontime) as totalexecutiontime,
    round(
        sum(executiontime) * 100 / max(t2.totalexecutiontime), 2
    ) as percentexecutiontime
from
    (
        select
            item.execution_time as executiontime,
            net.host(item.url) as requestdomain,
            domainsover50table.requestdomain as thirdpartydomain
        from
            `httparchive.lighthouse.2019_07_01_mobile`,
            unnest(getexecutiontimes(report)) as item
        left join
            `lighthouse-infrastructure.third_party_web.2019_07_01_all_observed_domains`
            as domainsover50table
            on net.host(item.url) = domainsover50table.requestdomain
    ) t1,
    (
        select sum(item.execution_time) as totalexecutiontime
        from
            `httparchive.lighthouse.2019_07_01_mobile`,
            unnest(getexecutiontimes(report)) as item
    ) t2
where thirdpartydomain is not null
group by thirdpartydomain
order by totalexecutiontime desc
limit 100
