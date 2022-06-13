# standardSQL
create temporary function getstylesheets(payload string)
returns struct < remote int64,
inline int64
> language js
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
    percentile,
    _table_suffix as client,
    countif(stylesheets.remote = 1) / count(0) as pct_1_remote,
    approx_quantiles(stylesheets.inline, 1000) [
        offset (percentile * 10)
    ] as num_inline_stylesheets,
    approx_quantiles(stylesheets.remote, 1000) [
        offset (percentile * 10)
    ] as num_remote_stylesheets
from
    (
        select _table_suffix, url, getstylesheets(payload) as stylesheets
        from `httparchive.pages.2020_08_01_*`
    ),
    unnest( [10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
