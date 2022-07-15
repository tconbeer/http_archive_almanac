# standardSQL
# 21_10: Top tag/importance combinations on priority hints.
create temporary function getpriorityhints(payload string)
returns array < struct < tag string,
importance string
>> language js as '''
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return almanac['priority-hints'].nodes.map(el => {
    return {
      tag: el.tagName,
      importance: el.importance
    };
  });
} catch (e) {
  return [];
}
'''
;

select
    _table_suffix as client,
    hint.tag,
    hint.importance,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct
from `httparchive.pages.2020_08_01_*`, unnest(getpriorityhints(payload)) as hint
group by client, tag, importance
order by pct desc
