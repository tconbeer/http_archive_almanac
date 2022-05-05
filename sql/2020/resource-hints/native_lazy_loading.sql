# standardSQL
# 21_12a: Count of pages using native lazy loading
create temporary function nativelazyloads(payload string)
returns boolean language js
as '''
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return almanac.images.loading_values.length > 0;
} catch (e) {
  return false;
}
'''
;

select
    _table_suffix as client,
    countif(nativelazyloads(payload)) as freq,
    count(0) as total,
    countif(nativelazyloads(payload)) / count(0) as pct
from `httparchive.pages.2020_08_01_*`
group by client
