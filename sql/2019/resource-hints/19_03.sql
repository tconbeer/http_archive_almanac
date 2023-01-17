# standardSQL
# 19_03: Attribute popularity for each hint.
create temporary function getresourcehints(payload string)
returns array<struct<name string, attribute string, value string>>
language js
as '''
var hints = new Set(['preload', 'prefetch', 'preconnect', 'prerender', 'dns-prefetch']);
var attributes = ['as', 'crossorigin'];
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return almanac['link-nodes'].reduce((results, link) => {
    var hint = link.rel.toLowerCase();
    if (!hints.has(hint)) {
      return results;
    }

    attributes.forEach(attribute => {
      var value = link[attribute];
      results.push({
        name: hint,
        attribute: attribute,
        // Support empty strings.
        value: typeof value == 'string' ? value : null
      });
    });

    return results;
  }, []);
} catch (e) {
  return [];
}
'''
;

select
    _table_suffix as client,
    hint.name,
    hint.attribute,
    ifnull(normalize_and_casefold(hint.value), 'not set') as value,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix, hint.name) as total,
    round(
        count(0) * 100 / sum(count(0)) over (partition by _table_suffix, hint.name), 2
    ) as pct
from `httparchive.pages.2019_07_01_*`, unnest(getresourcehints(payload)) as hint
group by client, name, attribute, value
order by freq desc
