# standardSQL
create temporary function getcombinedvariablenames(payload string) returns
array
< string
> language js
as '''
try {
  var $ = JSON.parse(payload);
  var scss = JSON.parse($['_sass']);
  if (!scss.scss) {
    return [];
  }

  return Object.keys(scss.scss.stats.variablesCombined.name);
} catch (e) {
  return [];
}
'''
;

select *
from
    (
        select
            _table_suffix as client,
            name,
            count(0) as freq,
            sum(count(0)) over (partition by _table_suffix) as total,
            count(0) / sum(count(0)) over (partition by _table_suffix) as pct
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(getcombinedvariablenames(payload)) as name
        group by client, name
    )
order by pct desc
limit 100
