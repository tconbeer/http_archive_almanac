# standardSQL
# Top manifest categories
create temporary function getcategories(manifest string)
returns array
< string
> language js
as '''
try {
  var $ = Object.values(JSON.parse(manifest))[0];
  var categories = $.categories;
  if (typeof categories == 'string') {
    return [categories];
  }
  return categories;
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

    manifests_categories as (
        select
            'All Sites' as type,
            _table_suffix as client,
            category,
            count(distinct url) as freq,
            total,
            count(distinct url) / total as pct,
            countif(
                json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
            ) as pwa_freq,
            pwa_total,
            countif(
                json_extract(payload, '$._pwa.serviceWorkerHeuristic') = 'true'
            ) / pwa_total as pwa_pct
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(getcategories(json_extract(payload, '$._pwa.manifests'))) as category
        join totals using(_table_suffix)
        where json_extract(payload, '$._pwa.manifests') != '[]'
        group by client, category, total, pwa_total
        having category is not null
        order by type desc, freq / total desc, category, client
    )

select
    'PWA Sites' as type,
    client,
    category,
    pwa_freq as freq,
    pwa_total as total,
    pwa_pct as pct
from manifests_categories
union all
select 'All Sites' as type, client, category, freq, total, pct
from manifests_categories
order by type desc, pct desc, category, client
