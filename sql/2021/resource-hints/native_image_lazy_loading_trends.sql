# standardSQL
# Trend of pages using native image lazy loading
create temporary function nativelazyloads(payload string)
returns boolean language js as '''
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return almanac.images.loading_values.length > 0;
} catch (e) {
  return false;
}
'''
;

with
    pages as (
        select '2019' as year, _table_suffix as client, *
        from `httparchive.pages.2019_07_01_*`
        union all
        select '2020' as year, _table_suffix as client, *
        from `httparchive.pages.2020_08_01_*`
        union all
        select '2021' as year, _table_suffix as client, *
        from `httparchive.pages.2021_07_01_*`
    )

select
    year,
    client,
    countif(nativelazyloads(payload)) as freq,
    count(0) as total,
    countif(nativelazyloads(payload)) / count(0) as pct
from pages
group by year, client
order by year, client
