# standardSQL
# Top 100 third party requests by total script execution time.
CREATE TEMPORARY FUNCTION getExecutionTimes(report STRING)
RETURNS ARRAY<STRUCT<url STRING, execution_time FLOAT64>>
LANGUAGE js AS '''
try {
  var $ = JSON.parse(report);
  return $.audits['bootup-time'].details.items.map(item => ({
    url: item.url,
    execution_time: item.scripting
  }));
} catch (e) {
  return [];
}
''';

select
    requesturl,
    count(0) as totalscripts,
    sum(executiontime) as totalexecutiontime,
    round(
        sum(executiontime) * 100 / max(t2.totalexecutiontime), 2
    ) as percentexecutiontime
from
    (
        select item.url as requesturl, item.execution_time as executiontime
        from
            `httparchive.lighthouse.2019_07_01_mobile`,
            unnest(getexecutiontimes(report)) as item
    ) t1,
    (
        select sum(item.execution_time) as totalexecutiontime
        from
            `httparchive.lighthouse.2019_07_01_mobile`,
            unnest(getexecutiontimes(report)) as item
    ) t2
where requesturl != 'Other'
group by requesturl
order by totalexecutiontime desc
limit 100
