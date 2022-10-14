# standardSQL
# Top manifest orientations
CREATE TEMP FUNCTION getOrientation(manifest STRING) RETURNS STRING LANGUAGE js AS '''
try {
  var $ = Object.values(JSON.parse(manifest))[0];
  if (!('orientation' in $)) {
    return '(not set)';
  }
  return $.orientation;
} catch {
  return '(not set)'
}
''';

select
    'PWA Sites' as type,
    _table_suffix as client,
    getorientation(json_extract(payload, '$._pwa.manifests')) as orientation,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct
from `httparchive.pages.2021_07_01_*`
where
    json_extract(payload, '$._pwa.manifests') != '[]'
    and json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
group by type, client, orientation
union all
select
    'All Sites' as type,
    _table_suffix as client,
    getorientation(json_extract(payload, '$._pwa.manifests')) as orientation,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct
from `httparchive.pages.2021_07_01_*`
where json_extract(payload, '$._pwa.manifests') != '[]'
group by type, client, orientation
order by type desc, freq / total desc, orientation, client
