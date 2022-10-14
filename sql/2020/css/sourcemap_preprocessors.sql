# standardSQL
# Adoption of preprocessors as a percent of pages that use sourcemaps.
CREATE TEMPORARY FUNCTION getSourcemappedExts(payload STRING) RETURNS ARRAY<STRING> LANGUAGE js AS '''
try {
  var $ = JSON.parse(payload);
  var sass = JSON.parse($._sass);
  return Object.keys(sass.sourcemaps.ext);
} catch (e) {
  return [];
}
''';

select
    _table_suffix as client,
    ext,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct
from `httparchive.pages.2020_08_01_*`, unnest(getsourcemappedexts(payload)) as ext
group by client, ext
order by pct desc
