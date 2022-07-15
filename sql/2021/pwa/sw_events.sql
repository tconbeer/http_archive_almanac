# standardSQL
# SW events
create temporary function getswevents(payload string)
returns array
< string
> language js as '''
try {
  var payloadJSON = JSON.parse(payload);
  var swEventListenersInfo = (Object.values(payloadJSON.swEventListenersInfo)).flat();
  var swPropertiesInfo = (Object.values(payloadJSON.swPropertiesInfo)).flat();
  return [...new Set([...swEventListenersInfo ,...swPropertiesInfo])];
} catch (e) {
  return [];
}
'''
;

select
    _table_suffix as client,
    event,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from
    `httparchive.pages.2021_07_01_*`,
    unnest(getswevents(json_extract(payload, '$._pwa'))) as event
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2021_07_01_*`
        where json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
        group by _table_suffix
    )
    using(_table_suffix)
where json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
group by client, total, event
order by freq / total desc, client
