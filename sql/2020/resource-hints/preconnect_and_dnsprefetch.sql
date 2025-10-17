# standardSQL
# 21_06: Frequency of link tags that set both preconnect & dns-prefetch
create temporary function preconnectsandprefetchesdns(payload string)
returns boolean
language js
as '''
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return !!almanac['link-nodes'].nodes.find((node) => {
    var rel = node.rel.toLowerCase();
    return rel.includes("preconnect") && rel.includes("dns-prefetch");
  });
} catch (e) {
  return false;
}
'''
;

select
    _table_suffix as client,
    countif(preconnectsandprefetchesdns(payload)) as freq,
    count(0) as total,
    countif(preconnectsandprefetchesdns(payload)) / count(0) as pct
from `httparchive.pages.2020_08_01_*`
group by client
