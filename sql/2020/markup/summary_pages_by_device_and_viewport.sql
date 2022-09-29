# standardSQL
# Viewport M219
create temp function as_percent(freq float64, total float64) returns float64 as (
    round(safe_divide(freq, total), 4)
)
;

create temporary function normalise(content string)
returns string language js
as '''
try {
  // split by ,
  // trim
  // lower case
  // alphabetize
  // re join by comma

  return content.split(",").map(c1 => c1.trim().toLowerCase().replace(/ +/g, "").replace(/\\.0*/,"")).sort().join(",");
} catch (e) {
  return '';
}
'''
;

select
    _table_suffix as client,
    normalise(meta_viewport) as meta_viewport,
    count(0) as freq,
    as_percent(count(0), sum(count(0)) over (partition by _table_suffix)) as pct_m219
from `httparchive.summary_pages.2020_08_01_*`
group by client, meta_viewport
order by freq desc, client
limit 100
