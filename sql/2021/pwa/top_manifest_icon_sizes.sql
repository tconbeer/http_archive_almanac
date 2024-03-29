# standardSQL
# Top manifest icon sizes
create temporary function geticonsizes(manifest string)
returns array<string>
language js
as '''
try {
  var $ = Object.values(JSON.parse(manifest))[0];
  return $.icons.map(icon => icon.sizes);
} catch (e) {
  return null;
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

    manifests_icon_sizes as (
        select
            'All Sites' as type,
            _table_suffix as client,
            size,
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
            unnest(geticonsizes(json_extract(payload, '$._pwa.manifests'))) as size
        join totals using (_table_suffix)
        where json_extract(payload, '$._pwa.manifests') != '[]'
        group by client, size, total, pwa_total
        having size is not null
        order by type desc, freq / total desc, size, client
    )

select
    'PWA Sites' as type,
    client,
    size,
    pwa_freq as freq,
    pwa_total as total,
    pwa_pct as pct
from manifests_icon_sizes
where size is not null and freq > 100
union all
select 'All Sites' as type, client, size, freq, total, pct
from manifests_icon_sizes
where size is not null and freq > 100
order by type desc, pct desc, size, client
