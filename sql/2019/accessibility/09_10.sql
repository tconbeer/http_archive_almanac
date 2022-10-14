# standardSQL
# 09_10: % of pages having skip links
CREATE TEMPORARY FUNCTION getEarlyHash(payload STRING)
RETURNS INT64 LANGUAGE js AS '''
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return almanac['seo-anchor-elements'].earlyHash;
} catch (e) {
  return 0;
}
''';

select
    _table_suffix as client,
    count(distinct url) as pages,
    total,
    round(count(distinct url) * 100 / total, 2) as pct
from `httparchive.pages.2019_07_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2019_07_01_*`
        group by _table_suffix
    ) using (_table_suffix)
where getearlyhash(payload) > 0
group by client, total
