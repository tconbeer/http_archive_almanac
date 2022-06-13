# standardSQL
# 10_05: structured data by @type
create temporary function getschematypes(payload string)
returns array
< string
> language js
as '''
  try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);
    return almanac['10.5'].map(element => {
        // strip any @context
        var split = element.split('/');
        return split[split.length - 1];
    });
  } catch (e) {
    return [];
  }
'''
;

select
    _table_suffix as client,
    schema_type,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    round(
        count(schema_type) * 100 / sum(count(0)) over (partition by _table_suffix), 2
    ) as pct
from `httparchive.pages.2019_07_01_*`, unnest(getschematypes(payload)) as schema_type
group by client, schema_type
order by freq / total desc
