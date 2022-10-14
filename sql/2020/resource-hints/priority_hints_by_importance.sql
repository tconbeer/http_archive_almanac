# standardSQL
# 21_09: Top importance values on priority hints.
CREATE TEMPORARY FUNCTION getPriorityHintImportance(payload STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return almanac['priority-hints'].nodes.map(el => el.importance);
} catch (e) {
  return [];
}
''';

select
    _table_suffix as client,
    importance,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct
from
    `httparchive.pages.2020_08_01_*`,
    unnest(getpriorityhintimportance(payload)) as importance
group by client, importance
order by pct desc
