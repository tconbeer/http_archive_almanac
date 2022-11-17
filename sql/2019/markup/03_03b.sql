# standardSQL
# 03_03b: Top custom elements ("slang")
create temporary function getcustomelements(payload string)
returns array<string>
language js
as '''
try {
  var $ = JSON.parse(payload);
  var elements = JSON.parse($._element_count);
  if (Array.isArray(elements) || typeof elements != 'object') return [];
  return Object.keys(elements).filter(e => e.includes('-'));
} catch (e) {
  return [];
}
'''
;

select
    _table_suffix as client,
    custom_element,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by _table_suffix), 2) as pct
from
    `httparchive.pages.2019_07_01_*`,
    unnest(getcustomelements(payload)) as custom_element
group by client, custom_element
order by freq / total desc, client
