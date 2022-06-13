# standardSQL
# Workbox usage
select
    _table_suffix as client,
    countif(json_extract(payload, '$._pwa.workboxInfo') != '[]') as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    countif(json_extract(payload, '$._pwa.workboxInfo') != '[]') / sum(
        count(0)
    ) over (partition by _table_suffix) as pct
from `httparchive.pages.2021_07_01_*`
where
    json_extract(payload, '$._pwa.manifests') != '[]' and json_extract(
        payload, '$._pwa.serviceWorkerHeuristic'
    ) = 'true'
group by client
order by freq / total desc, client
