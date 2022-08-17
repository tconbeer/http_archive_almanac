# standardSQL
# 11_04c: Top manifest display values
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
    getdisplay(body) as display,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from `httparchive.almanac.manifests`
where date = '2019-07-01'
group by client, display
having display is not null
order by freq / total desc
