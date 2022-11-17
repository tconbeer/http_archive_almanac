# standardSQL
create temporary function countcombinedvariables(payload string)
returns array<struct<usage string, freq int64>>
language js
as
    '''
try {
  var $ = JSON.parse(payload);
  var scss = JSON.parse($['_sass']);
  if (!scss.scss) {
    return [];
  }

  return Object.entries(scss.scss.stats.variablesCombined).map(([usage, obj]) => ({usage, freq: Object.keys(obj).length}));
} catch (e) {
  return [];
}
'''
;

select
    client,
    usage,
    countif(freq > 0) as sass_pages_with_combined_variables,
    count(0) as total_sass_pages,
    total as total_all_pages,
    countif(freq > 0) / count(0) as pct_sass_pages,
    countif(freq > 0) / total as pct_all_pages
from
    (
        select _table_suffix as client, var.usage, var.freq
        from
            `httparchive.pages.2020_08_01_*`,
            unnest(countcombinedvariables(payload)) as var
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by client
    ) using (client)
group by client, usage, total
