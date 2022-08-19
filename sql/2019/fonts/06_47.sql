# standardSQL
# 06_47: % of pages linking to a Google Fonts stylesheet as first item in <head>
create temp function preloadsgooglefontfirst(payload string)
returns boolean language js as '''
  try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);
    return !!almanac['06.47'] == 1;
  } catch (e) {
    return false;
  }

'''
;

select
    _table_suffix as client,
    countif(preloadsgooglefontfirst(payload)) as freq,
    count(0) as total,
    round(countif(preloadsgooglefontfirst(payload)) * 100 / count(0), 2) as pct
from `httparchive.pages.2019_07_01_*`
group by client
