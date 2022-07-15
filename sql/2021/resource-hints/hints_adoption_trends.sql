# standardSQL
# trends of sites that use each type of resource hint.
create temporary function getresourcehints(payload string)
returns struct < preload boolean,
prefetch boolean,
preconnect boolean,
prerender boolean,
`dns-prefetch` boolean,
`modulepreload` boolean
> language js
as '''
var hints = ['preload', 'prefetch', 'preconnect', 'prerender', 'dns-prefetch', 'modulepreload'];
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return hints.reduce((results, hint) => {
    if (almanac['link-nodes'].nodes) {
      results[hint] = !!almanac['link-nodes'].nodes.find(link => link.rel.toLowerCase() == hint);
    } else {
      // in 2019 we did not have the `.nodes property`
      results[hint] = !!almanac['link-nodes'].find(link => link.rel.toLowerCase() == hint);
    }
    return results;
  }, {});
} catch (e) {
  return hints.reduce((results, hint) => {
    results[hint] = false;
    return results;
  }, {});
}
'''
;

with
    pages as (
        select '2019' as year, _table_suffix as client, *
        from `httparchive.pages.2019_07_01_*`
        union all
        select '2020' as year, _table_suffix as client, *
        from `httparchive.pages.2020_08_01_*`
        union all
        select '2021' as year, _table_suffix as client, *
        from `httparchive.pages.2021_07_01_*`
    )

select
    year,
    client,
    count(0) as total,
    countif(hints.preload) as preload,
    countif(hints.preload) / count(0) as pct_preload,
    countif(hints.prefetch) as prefetch,
    countif(hints.prefetch) / count(0) as pct_prefetch,
    countif(hints.preconnect) as preconnect,
    countif(hints.preconnect) / count(0) as pct_preconnect,
    countif(hints.prerender) as prerender,
    countif(hints.prerender) / count(0) as pct_prerender,
    countif(hints.`dns-prefetch`) as dns_prefetch,
    countif(hints.`dns-prefetch`) / count(0) as pct_dns_prefetch,
    countif(hints.modulepreload) as modulepreload,
    countif(hints.modulepreload) / count(0) as pct_modulepreload
from (select client, year, getresourcehints(payload) as hints from pages)
group by year, client
order by year, client
