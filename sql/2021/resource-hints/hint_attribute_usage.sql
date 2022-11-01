# standardSQL
# Attribute popularity for each hint.
create temporary function getresourcehintattrs(payload string)
returns array<struct<name string, attribute string, value string>>
language js
as '''
var hints = new Set(['preload', 'prefetch', 'preconnect', 'prerender', 'dns-prefetch']);
var attributes = ['as', 'crossorigin', 'media'];
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
    client,
    name,
    attribute,
    value,
    count(0) as freq,
    sum(count(0)) over (partition by client, name, attribute) as total,
    count(0) / sum(count(0)) over (partition by client, name, attribute) as pct
from
    (
        select
            _table_suffix as client,
            hint.name as name,
            hint.attribute as attribute,
            ifnull(trim(normalize_and_casefold(hint.value)), 'not set') as value
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(getresourcehintattrs(payload)) as hint
    )
group by client, name, attribute, value
order by client, name, attribute, value, pct desc
