# standardSQL
# Top manifest display values - based on 2019/14_04c.sql
create temporary function getdisplay(manifest string)
returns string language js as '''
try {
  var $ = JSON.parse(manifest);
  if (!('display' in $)) {
    return '(not set)';
  }
  return $.display;
} catch (e) {
  return null;
}
'''
;

select
    client,
    lower(getdisplay(body)) as display,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select distinct client, body
        from `httparchive.almanac.manifests`
        join `httparchive.almanac.service_workers` using(date, client, page)
        where date = '2020-08-01'
    )
group by client, display
having display is not null
order by freq / total desc, display, client
