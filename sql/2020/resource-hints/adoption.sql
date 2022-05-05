# standardSQL
# 21_01: % of sites that use each type of hint.
create temporary function getresourcehints(payload string)
returns struct < preload boolean,
prefetch boolean,
preconnect boolean,
prerender boolean,
`dns-prefetch` boolean
>
language js
as '''
var hints = ['preload', 'prefetch', 'preconnect', 'prerender', 'dns-prefetch'];
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return hints.reduce((results, hint) => {
    results[hint] = !!almanac['link-nodes'].nodes.find(link => link.rel.toLowerCase() == hint);
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

select
    client,
    countif(hints.preload) as preload,
    countif(hints.preload) / count(0) as pct_preload,
    countif(hints.prefetch) as prefetch,
    countif(hints.prefetch) / count(0) as pct_prefetch,
    countif(hints.preconnect) as preconnect,
    countif(hints.preconnect) / count(0) as pct_preconnect,
    countif(hints.prerender) as prerender,
    countif(hints.prerender) / count(0) as pct_prerender,
    countif(hints.`dns-prefetch`) as dns_prefetch,
    countif(hints.`dns-prefetch`) / count(0) as pct_dns_prefetch
from
    (
        select _table_suffix as client, getresourcehints(payload) as hints
        from `httparchive.pages.2020_08_01_*`
    )
group by client
