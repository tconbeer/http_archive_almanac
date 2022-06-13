# standardSQL
# 19_07: % of sites that use priority hints.
create temporary function getpriorityhints(payload string)
returns boolean language js
as '''
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return almanac['priority-hints'].length > 0;
} catch (e) {
  return false;
}
'''
;

select
    client,
    countif(has_hint) as freq,
    count(0) as total,
    round(countif(has_hint) * 100 / count(0), 2) as pct
from
    (
        select _table_suffix as client, getpriorityhints(payload) as has_hint
        from `httparchive.pages.2019_07_01_*`
    )
group by client
