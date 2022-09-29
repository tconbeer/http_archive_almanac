# standardSQL
create temporary function getmarkupdirs(payload string)
returns array < struct < element string,
value string
>> language js as '''
try {
  var $ = JSON.parse(payload);
  var dirs = JSON.parse($._markup).dirs;
  var result = [];

  result.push({
    element: 'html',
    value: dirs.html_dir.trim().toLowerCase()
  });

  Object.entries(dirs.body_nodes_dir.values).forEach(([value, freq]) => {
    result.push({
      element: 'body',
      value: value.trim().toLowerCase()
    });
  });

  return result;
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
            dir.element,
            dir.value,
            count(0) as freq,
            sum(count(0)) over (partition by _table_suffix, dir.element) as total,
            count(0)
            / sum(count(0)) over (partition by _table_suffix, dir.element) as pct
        from `httparchive.pages.2020_08_01_*`, unnest(getmarkupdirs(payload)) as dir
        group by client, element, value
    )
where freq >= 100
order by pct desc
