# standardSQL
# 10_03: <link rel="amphtml"> (AMP)
create temp function hasamplink(payload string)
returns boolean language js
as '''
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return !!almanac['link-nodes'].find(node => node.rel.toLowerCase() == 'amphtml');
} catch (e) {
  return false;
}
'''
;

select
    client,
    countif(has_amp_link) as freq,
    count(0) as total,
    round(countif(has_amp_link) * 100 / count(0), 2) as pct
from
    (
        select _table_suffix as client, hasamplink(payload) as has_amp_link
        from `httparchive.pages.2019_07_01_*`
    )
group by client
