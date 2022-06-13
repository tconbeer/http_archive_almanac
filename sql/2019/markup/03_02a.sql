# standardSQL
# 03_02a: % of pages having elements
create temporary function getelements(payload string)
returns array
< string
> language js
as '''
try {
  var $ = JSON.parse(payload);
  var elements = JSON.parse($._element_count);
  if (Array.isArray(elements) || typeof elements != 'object') return [];
  return Object.keys(elements);
} catch (e) {
  return [];
}
'''
;

select
    _table_suffix as client,
    element,
    count(distinct url) as pages,
    total,
    round(count(distinct url) * 100 / total, 2) as pct
from `httparchive.pages.2019_07_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2019_07_01_*`
        group by _table_suffix
    )
    using(_table_suffix),
    unnest(getelements(payload)) as element
group by client, total, element
order by pages / total desc, client
