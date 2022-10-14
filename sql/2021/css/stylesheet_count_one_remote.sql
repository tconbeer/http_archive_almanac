# standardSQL
CREATE TEMPORARY FUNCTION getStylesheets(payload STRING)
RETURNS STRUCT<remote INT64, inline INT64> LANGUAGE js AS '''
try {
  var $ = JSON.parse(payload)
  var sass = JSON.parse($._sass);
  return sass.stylesheets;
} catch (e) {
  return null;
}
''';

select
    _table_suffix as client,
    countif(stylesheets.remote = 1) as one_remote,
    count(0) as total,
    countif(stylesheets.remote = 1) / count(0) as pct_one_remote
from
    (
        select _table_suffix, url, getstylesheets(payload) as stylesheets
        from `httparchive.pages.2021_07_01_*`
    )
group by client
order by client
