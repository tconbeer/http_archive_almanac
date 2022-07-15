# standardSQL
# 21_07: % of sites that use priority hints.
create temporary function haspriorityhints(payload string)
returns boolean language js as '''
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return almanac['priority-hints'].nodes.length > 0;
} catch (e) {
  return false;
}
'''
;

select
    client,
    countif(has_hint) as freq,
    count(0) as total,
    countif(has_hint) / count(0) as pct
from
    (
        select _table_suffix as client, haspriorityhints(payload) as has_hint
        from `httparchive.pages.2020_08_01_*`
    )
group by client
