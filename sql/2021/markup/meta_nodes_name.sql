# standardSQL
# meta nodes
create temporary function getmetanodes(payload string)
returns array
< string
>
language js
as '''
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return almanac['meta-nodes'].nodes.map(n => n.name || n.property);
} catch (e) {
  return [];
}
'''
;

with
    totals as (
        select _table_suffix, count(0) as total_pages
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )

select
    _table_suffix as client,
    if(ifnull(trim(name), '') = '', '(not set)', name) as name,
    count(0) as freq,
    count(0) / sum(count(0)) over () as pct_nodes,
    count(distinct url) as num_urls,
    count(distinct url) / total_pages as pct_pages
from `httparchive.pages.2021_07_01_*`, unnest(getmetanodes(payload)) as name
join totals using(_table_suffix)
group by client, total_pages, name
having freq > 1
order by pct_nodes desc, client, name
limit 200
