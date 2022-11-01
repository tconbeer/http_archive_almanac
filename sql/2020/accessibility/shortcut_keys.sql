# standardSQL
# Most popular accesskey or aria-keyshortcuts keys
create temporary function getshortcuts(payload string)
returns array<struct<type string, shortcut string>>
language js
as '''
try {
  const almanac = JSON.parse(payload);

  const collector = [];
  function addToCollector(array, type) {
    // remove any possible dupes
    let arr_deduped = new Set(array);
    arr_deduped.forEach((shortcut) => collector.push({type, shortcut}));
  }

  addToCollector(
      almanac.shortcuts_stats.aria_shortcut_values,
      'aria_shortcut');
  addToCollector(
      almanac.shortcuts_stats.accesskey_values,
      'accesskey');

  return collector;
} catch (e) {
  return [];
}
'''
;

select
    _table_suffix as client,
    type_and_key.type as type,
    sum(count(0)) over (partition by _table_suffix, type) as total_type_uses,

    type_and_key.shortcut as shortcut,
    count(0) as total_uses,
    count(0) / sum(count(0)) over (partition by _table_suffix, type) as pct_of_type_uses
from
    `httparchive.pages.2020_08_01_*`,
    unnest(getshortcuts(json_extract_scalar(payload, '$._almanac'))) as type_and_key
group by client, type_and_key.type, type_and_key.shortcut
having total_uses >= 100
order by total_uses desc
