# standardSQL
# 03_02b: Top elements
create temporary function getelements(payload string)
returns array < struct < name string,
freq int64
>> language js
as '''
try {
  var $ = JSON.parse(payload);
  var elements = JSON.parse($._element_count);
  if (Array.isArray(elements) || typeof elements != 'object') return [];
  return Object.entries(elements).map(([name, freq]) => ({name, freq}));
} catch (e) {
  return [];
}
'''
;

select
    _table_suffix as client,
    element.name,
    sum(element.freq) as freq,
    sum(sum(element.freq)) over (partition by _table_suffix) as total,
    round(
        sum(element.freq) * 100 / sum(
            sum(element.freq)
        ) over (partition by _table_suffix),
        2
    ) as pct
from `httparchive.pages.2019_07_01_*`, unnest(getelements(payload)) as element
group by client, element.name
order by freq / total desc, client
limit 10000
