# standardSQL
# Manifests that are not JSON parsable for service worker pages and all pages
create temp function canparsemanifest(manifest string)
returns boolean language js as '''
try {
  var manifestJSON = Object.values(JSON.parse(manifest))[0];
  if (typeof manifestJSON === 'string' && manifestJSON.trim() != '') {
    return false;
  }
  if (typeof manifestJSON === 'string' && manifestJSON.trim() === '') {
    return null;
  }
  return true;
} catch {
  return false;
}
'''
;

select
    'PWA Pages' as type,
    _table_suffix as client,
    canparsemanifest(json_extract(payload, '$._pwa.manifests')) as can_parse,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct
from `httparchive.pages.2021_07_01_*`
where
    json_extract(payload, '$._pwa.manifests') != '[]'
    and json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
group by client, can_parse
union all
select
    'All Pages' as type,
    _table_suffix as client,
    canparsemanifest(json_extract(payload, '$._pwa.manifests')) as can_parse,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct
from `httparchive.pages.2021_07_01_*`
group by client, can_parse
order by type desc, freq / total desc, can_parse, client
