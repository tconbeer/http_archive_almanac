# standardSQL
# 19_04: Popular resource types to preload/prefecth.
create temporary function getresourcehints(payload string)
returns array<struct<name string, href string>>
language js
as '''
var hints = new Set(['preload', 'prefetch']);
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return almanac['link-nodes'].reduce((results, link) => {
    var hint = link.rel.toLowerCase();
    if (!hints.has(hint)) {
      return results;
    }

    results.push({
      name: hint,
      href: link.href
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
    name,
    type,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix, name) as total,
    round(
        count(0) * 100 / sum(count(0)) over (partition by _table_suffix, name), 2
    ) as pct
from
    (
        select _table_suffix, url as page, hint.name, hint.href as url
        from `httparchive.pages.2019_07_01_*`, unnest(getresourcehints(payload)) as hint
    )
left join
    (
        select client as _table_suffix, page, url, type
        from `httparchive.almanac.summary_requests`
        where date = '2019-07-01'
    ) using (_table_suffix, page, url)
group by client, name, type
order by freq desc
