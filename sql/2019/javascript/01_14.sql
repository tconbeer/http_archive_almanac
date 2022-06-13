# standardSQL
# 01_14: Percent of pages that include link[rel=preload][as=script]
create temp function hasscriptpreload(payload string)
returns boolean language js
as '''
  try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);
    return !!almanac['link-nodes'].find(e => e.rel.toLowerCase() == 'preload' && e.as.toLowerCase() == 'script');
  } catch (e) {
    return false;
  }

'''
;

select
    _table_suffix as client,
    countif(hasscriptpreload(payload)) as num_pages,
    count(0) as total,
    round(countif(hasscriptpreload(payload)) * 100 / count(0), 2) as pct_script_preload
from `httparchive.pages.2019_07_01_*`
group by client
