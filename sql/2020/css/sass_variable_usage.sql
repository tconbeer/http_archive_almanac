# standardSQL
create temporary function getvariableusage(payload string) returns
array < struct < variable string,
freq int64
>> language js as '''
try {
  var $ = JSON.parse(payload);
  var scss = JSON.parse($['_sass']);
  if (!scss.scss) {
    return [];
  }

  return Object.entries(scss.scss.stats.variables).map(([variable, freq]) => {
    return {variable, freq};
  });
} catch (e) {
  return [];
}
'''
;

select
    client,
    variable,
    count(distinct page) as pages,
    sum(freq) as freq,
    sum(sum(freq)) over (partition by client) as total,
    sum(freq) / sum(sum(freq)) over (partition by client) as pct
from
    (
        select _table_suffix as client, url as page, variable.variable, variable.freq
        from
            `httparchive.pages.2020_08_01_*`,
            unnest(getvariableusage(payload)) as variable
    )
group by client, variable
order by pct desc
limit 500
