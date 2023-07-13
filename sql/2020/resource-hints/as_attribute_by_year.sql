# standardSQL
# 21_03: Attribute popularity for each hint.
create temporary function getresourcehintattrs(payload string)
returns array<struct<name string, attribute string, value string>>
language js
as '''
var hints = new Set(['preload', 'prefetch', 'preconnect', 'prerender', 'dns-prefetch']);
var attributes = ['as', 'crossorigin', 'media'];
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  var nodes = almanac['link-nodes'].nodes || almanac['link-nodes'];
  return nodes.reduce((results, link) => {
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

with
    pages as (
        select _table_suffix, 2020 as year, payload
        from `httparchive.pages.2020_08_01_*`
        union all
        select _table_suffix, 2019 as year, payload
        from `httparchive.pages.2019_07_01_*`
    )

select
    year,
    _table_suffix as client,
    ifnull(normalize_and_casefold(hint.value), 'not set') as value,
    count(0) as freq,
    sum(count(0)) over (partition by year, _table_suffix) as total,
    count(0) / sum(count(0)) over (partition by year, _table_suffix) as pct
from pages, unnest(getresourcehintattrs(payload)) as hint
where name in ('preload', 'prefetch') and attribute = 'as'
group by year, client, value
order by pct desc
