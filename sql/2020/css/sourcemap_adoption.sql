# standardSQL
# Percent of pages with CSS sourcemaps.
create temporary function countsourcemaps(payload string)
returns int64
language js
as '''
try {
  var $ = JSON.parse(payload);
  var sass = JSON.parse($._sass);
  return sass.sourcemaps.count;
} catch (e) {
  return 0;
}
'''
;

select
    client,
    countif(has_sourcemap) as freq,
    count(0) as total,
    countif(has_sourcemap) / count(0) as pct
from
    (
        select _table_suffix as client, countsourcemaps(payload) > 0 as has_sourcemap
        from `httparchive.pages.2020_08_01_*`
    )
group by client
