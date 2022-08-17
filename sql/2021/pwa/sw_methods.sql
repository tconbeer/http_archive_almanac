# standardSQL
# SW methods
create temporary function getswmethods(swmethodsinfo string)
returns array
< string
> language js as '''
try {
  var swMethods = JSON.parse(swMethodsInfo);
  return Array.from(new Set(Object.values(swMethods).flat()));
} catch (e) {
  return [];
}
'''
;

select
    _table_suffix as client,
    sw_method,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from
    `httparchive.pages.2021_07_01_*`,
    unnest(getswmethods(json_extract(payload, '$._pwa.swMethodsInfo'))) as sw_method
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2021_07_01_*`
        where json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
        group by _table_suffix
    ) using (_table_suffix)
where
    json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
    and json_extract(payload, '$._pwa.swMethodsInfo') != '[]'
group by client, total, sw_method
order by freq / total desc, client
