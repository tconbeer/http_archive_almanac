# standardSQL
# 06_46: % of pages linking to a Google Fonts stylesheet
create temp function preloadsgooglefont(payload string)
returns boolean language js
as '''
  try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);
    return !!almanac['link-nodes'].find(e => e.rel.toLowerCase() == 'stylesheet' && (e.href.startsWith('https://fonts.googleapis.com') || e.href.startsWith('http://fonts.googleapis.com')));
  } catch (e) {
    return false;
  }

'''
;

select
    _table_suffix as client,
    countif(preloadsgooglefont(payload)) as freq,
    count(0) as total,
    round(countif(preloadsgooglefont(payload)) * 100 / count(0), 2) as pct
from `httparchive.pages.2019_07_01_*`
group by client
