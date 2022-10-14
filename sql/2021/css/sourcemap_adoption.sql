# standardSQL
# Percent of pages with CSS sourcemaps.
CREATE TEMPORARY FUNCTION countSourcemaps(payload STRING) RETURNS INT64 LANGUAGE js AS '''
try {
  var $ = JSON.parse(payload);
  var sass = JSON.parse($._sass);
  return sass.sourcemaps.count;
} catch (e) {
  return 0;
}
''';

select
    client,
    countif(has_sourcemap) as freq,
    count(0) as total,
    countif(has_sourcemap) / count(0) as pct
from
    (
        select _table_suffix as client, countsourcemaps(payload) > 0 as has_sourcemap
        from `httparchive.pages.2021_07_01_*`
    )
group by client
