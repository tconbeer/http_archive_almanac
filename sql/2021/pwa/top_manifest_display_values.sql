# standardSQL
# Top most used display values in manifest files
create temp function getdisplay(manifest string) returns string language js
as '''
try {
  var $ = Object.values(JSON.parse(manifest))[0];
  if (!('display' in $)) {
    return '(not set)';
  }
  return $.display;
} catch {
  return '(not set)'
}
'''
;

select
    'PWA Sites' as type,
    _table_suffix as client,
    getdisplay(json_extract(payload, '$._pwa.manifests')) as display,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct
from `httparchive.pages.2021_07_01_*`
where
    json_extract(payload, '$._pwa.manifests') != '[]' and json_extract(
        payload, '$._pwa.serviceWorkerHeuristic'
    ) = 'true'
group by client, display
qualify display is not null and freq > 100
union all
select
    'All Sites' as type,
    _table_suffix as client,
    getdisplay(json_extract(payload, '$._pwa.manifests')) as display,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct
from `httparchive.pages.2021_07_01_*`
where json_extract(payload, '$._pwa.manifests') != '[]'
group by client, display
qualify display is not null and freq > 100
order by type desc, freq / total desc, display, client
