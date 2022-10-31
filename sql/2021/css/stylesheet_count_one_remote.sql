# standardSQL
create temporary function getstylesheets(payload string)
returns struct<remote int64, inline int64>
language js
as '''
try {
  var $ = JSON.parse(payload)
  var sass = JSON.parse($._sass);
  return sass.stylesheets;
} catch (e) {
  return null;
}
'''
;

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
