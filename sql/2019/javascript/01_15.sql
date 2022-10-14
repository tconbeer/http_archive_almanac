# standardSQL
# 01_15: Percent of pages that include link[rel=modulepreload]
CREATE TEMP FUNCTION hasModulePreload(payload STRING)
RETURNS BOOLEAN LANGUAGE js AS '''
  try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);
    return !!almanac['link-nodes'].find(e => e.rel.toLowerCase() == 'modulepreload');
  } catch (e) {
    return false;
  }

''';

select
    _table_suffix as client,
    countif(hasmodulepreload(payload)) as num_pages,
    count(0) as total,
    round(countif(hasmodulepreload(payload)) * 100 / count(0), 2) as pct_modulepreload
from `httparchive.pages.2019_07_01_*`
group by client
