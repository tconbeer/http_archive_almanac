# standardSQL
# 03_03a: % of pages with custom elements ("slang")
create temporary function containscustomelement(payload string)
returns boolean language js
as '''
try {
  var $ = JSON.parse(payload);
  var elements = JSON.parse($._element_count)
  return Object.keys(elements).filter(e => e.includes('-')).length > 0;
} catch (e) {
  return false;
}
'''
;

select
    _table_suffix as client,
    countif(containscustomelement(payload)) as pages,
    round(countif(containscustomelement(payload)) * 100 / count(0), 2) as pct_pages
from `httparchive.pages.2019_07_01_*`
group by client
