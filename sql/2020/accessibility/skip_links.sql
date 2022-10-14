# standardSQL
# % of pages having skip links
CREATE TEMPORARY FUNCTION getEarlyHash(payload STRING)
RETURNS INT64 LANGUAGE js AS '''
try {
  const almanac = JSON.parse(payload);
  return almanac['seo-anchor-elements'].earlyHash;
} catch (e) {
  return 0;
}
''';

select
    _table_suffix as client,
    countif(getearlyhash(json_extract_scalar(payload, '$._almanac')) > 0) as pages,
    count(0) as total,
    countif(getearlyhash(json_extract_scalar(payload, '$._almanac')) > 0)
    / count(0) as pct
from `httparchive.pages.2020_08_01_*`
group by client
