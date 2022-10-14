# standardSQL
# % manifests preferring native apps for service worker pages and all pages
CREATE TEMP FUNCTION prefersNative(manifest STRING)
RETURNS BOOLEAN LANGUAGE js AS '''
try {
  var $ = Object.values(JSON.parse(manifest))[0];
  return $.prefer_related_applications == true && $.related_applications.length > 0;
} catch (e) {
  return null;
}
''';

select
    'PWA Pages' as type,
    _table_suffix as client,
    prefersnative(json_extract(payload, '$._pwa.manifests')) as prefersnative,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct
from `httparchive.pages.2021_07_01_*`
where
    json_extract(payload, '$._pwa.manifests') != '[]'
    and json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
group by client, prefersnative
union all
select
    'All Pages' as type,
    _table_suffix as client,
    prefersnative(json_extract(payload, '$._pwa.manifests')) as prefersnative,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct
from `httparchive.pages.2021_07_01_*`
group by client, prefersnative
order by type desc, freq / total desc, prefersnative, client
