# standardSQL
# meta viewport
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
    sum(count(0)) over (partition by _table_suffix) as total,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct
from `httparchive.summary_pages.2021_07_01_*`
group by client, meta_viewport
order by pct desc, client, freq desc
limit 100
