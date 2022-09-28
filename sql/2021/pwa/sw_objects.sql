# standardSQL
# SW objects
create temporary function getswobjects(swobjectsinfo string)
returns array
< string
> language js as '''
try {
  var swObjects = Object.values(JSON.parse(swObjectsInfo));
  if (typeof swObjects != 'string') {
    swObjects = swObjects.toString();
  }
  swObjects = swObjects.trim().split(',');
  return Array.from(new Set(swObjects));
} catch (e) {
  return [];
}
'''
;
select
    _table_suffix as client,
    sw_object,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from
    `httparchive.pages.2021_07_01_*`,
    unnest(getswobjects(json_extract(payload, '$._pwa.swObjectsInfo'))) as sw_object
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2021_07_01_*`
        where json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
        group by _table_suffix
    ) using (_table_suffix)
where
    json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
    and json_extract(payload, '$._pwa.swObjectsInfo') != '[]'
group by client, total, sw_object
order by freq / total desc, client
