# standardSQL
# 21_08: Top tags that use priority hints
create temporary function getpriorityhints(payload string)
returns array
< string
> language js as '''
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return almanac['priority-hints'].nodes.map(el => el.tagName);
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
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct
from `httparchive.pages.2020_08_01_*`, unnest(getpriorityhints(payload)) as tag
where tag is not null
group by client, tag
order by pct desc
