# standardSQL
# Top manifest properties
create temp function getmanifestprops(manifest string)
returns array
< string
> language js as '''
try {
  var manifestJSON = Object.values(JSON.parse(manifest))[0];
  if (typeof manifestJSON === 'string') {
    return null;
  }
  return Object.keys(manifestJSON);
} catch {
  return null
}
'''
;

with
    totals as (
        select
            _table_suffix,
            count(0) as total,
            countif(
                json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
            ) as pwa_total
        from `httparchive.pages.2021_07_01_*`
        where json_extract(payload, '$._pwa.manifests') != '[]'
        group by _table_suffix
    ),

    manifests_properties as (
        select
            'All Sites' as type,
            _table_suffix as client,
            property,
            count(distinct url) as freq,
            total,
            count(distinct url) / total as pct,
            countif(
                json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
            ) as pwa_freq,
            pwa_total,
            countif(json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true')
            / pwa_total as pwa_pct
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(
                getmanifestprops(json_extract(payload, '$._pwa.manifests'))
            ) as property
        join totals using (_table_suffix)
        where json_extract(payload, '$._pwa.manifests') != '[]'
        group by client, property, total, pwa_total
        having property is not null
        order by type desc, freq / total desc, property, client
    )

select
    'PWA Sites' as type,
    client,
    property,
    pwa_freq as freq,
    pwa_total as total,
    pwa_pct as pct
from manifests_properties
where property is not null and freq > 100
union all
select 'All Sites' as type, client, property, freq, total, pct
from manifests_properties
where property is not null and freq > 100
order by type desc, pct desc, property, client
