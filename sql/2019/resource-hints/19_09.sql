# standardSQL
# 19_09: Top importance values on priority hints.
create temporary function getpriorityhints(payload string)
returns array<string>
language js
as '''
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return almanac['priority-hints'].map(el => el.importance);
} catch (e) {
  return [];
}
'''
;

select
    _table_suffix as client,
    importance,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by _table_suffix), 2) as pct
from `httparchive.pages.2019_07_01_*`, unnest(getpriorityhints(payload)) as importance
where importance is not null
group by client, importance
order by freq desc
