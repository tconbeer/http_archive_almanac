# standardSQL
# 03_06b: Element types per page
create temporary function countelementtypes(payload string)
returns int64 language js
as '''
try {
  var $ = JSON.parse(payload);
  var elements = JSON.parse($._element_count);
  if (Array.isArray(elements) || typeof elements != 'object') return null;
  return Object.keys(elements).length;
} catch (e) {
  return null;
}
'''
;

select
    _table_suffix as client,
    countelementtypes(payload) as element_types,
    count(0) as freq
from `httparchive.pages.2019_07_01_*`
group by client, element_types
having element_types is not null
order by element_types, client
