# standardSQL
# Attribute popularity for imagesrcset and imagesizes on rel="preload"
create temporary function getresourcehintattrs(payload string)
returns array<struct<name string, attribute string, value string>>
language js
as '''
var hints = new Set(['preload']);
var attributes = ['imagesrcset', 'imagesizes'];
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return almanac['link-nodes'].nodes.reduce((results, link) => {
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
    hint.name as name,
    hint.attribute as attribute,
    countif(hint.value is not null) as freq,
    sum(count(0)) over (partition by _table_suffix, hint.name) as total,
    countif(hint.value is not null)
    / sum(count(0)) over (partition by _table_suffix, hint.name) as pct
from `httparchive.pages.2021_07_01_*`, unnest(getresourcehintattrs(payload)) as hint
group by client, name, attribute
order by client, name, attribute, pct desc
