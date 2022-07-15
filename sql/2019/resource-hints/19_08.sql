# standardSQL
# 19_08: Top tags that use priority hints
create temporary function getpriorityhints(payload string)
returns array
< string
> language js as '''
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return almanac['priority-hints'].map(el => el.tagName);
} catch (e) {
  return [];
}
'''
;

select
    _table_suffix as client,
    tag,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by _table_suffix), 2) as pct
from `httparchive.pages.2019_07_01_*`, unnest(getpriorityhints(payload)) as tag
where tag is not null
group by client, tag
order by freq desc
