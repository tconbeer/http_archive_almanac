# standardSQL
# 19_01: % of sites that use each type of hint.
create temporary function getresourcehints(payload string)
returns struct < preload boolean,
prefetch boolean,
preconnect boolean,
prerender boolean,
`dns-prefetch` boolean
> language js
as '''
var hints = ['preload', 'prefetch', 'preconnect', 'prerender', 'dns-prefetch'];
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return hints.reduce((results, hint) => {
    results[hint] = !!almanac['link-nodes'].find(link => link.rel.toLowerCase() == hint);
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
    round(countif(hints.preload) * 100 / count(0), 2) as pct_preload,
    countif(hints.prefetch) as prefetch,
    round(countif(hints.prefetch) * 100 / count(0), 2) as pct_prefetch,
    countif(hints.preconnect) as preconnect,
    round(countif(hints.preconnect) * 100 / count(0), 2) as pct_preconnect,
    countif(hints.prerender) as prerender,
    round(countif(hints.prerender) * 100 / count(0), 2) as pct_prerender,
    countif(hints.`dns-prefetch`) as dns_prefetch,
    round(countif(hints.`dns-prefetch`) * 100 / count(0), 2) as pct_dns_prefetch
from
    (
        select _table_suffix as client, getresourcehints(payload) as hints
        from `httparchive.pages.2019_07_01_*`
    )
group by client
