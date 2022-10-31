# standardSQL
# 01_16: Percent of pages that include link[rel=prefetch][as=script]
create temp function hasscriptprefetch(payload string)
returns boolean
language js
as
    '''
  try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);
    return !!almanac['link-nodes'].find(e => e.rel.toLowerCase() == 'prefetch' && e.as.toLowerCase() == 'script');
  } catch (e) {
    return false;
  }

'''
;

select
    _table_suffix as client,
    countif(hasscriptprefetch(payload)) as num_pages,
    count(0) as total,
    round(
        countif(hasscriptprefetch(payload)) * 100 / count(0), 2
    ) as pct_script_prefetch
from `httparchive.pages.2019_07_01_*`
group by client
