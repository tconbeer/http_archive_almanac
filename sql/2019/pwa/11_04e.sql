# standardSQL
# 11_04e: % manifests preferring native apps
create temporary function prefersnative(manifest string)
returns boolean language js
as '''
try {
  var $ = JSON.parse(manifest);
  return $.prefer_related_applications == true && $.related_applications.length > 0;
} catch (e) {
  return null;
}
'''
;

select
    client,
    prefersnative(body) as prefers_native,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from `httparchive.almanac.manifests`
where date = '2019-07-01'
group by client, prefers_native
having prefers_native is not null
order by freq / total desc
