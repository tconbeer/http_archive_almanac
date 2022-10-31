# standardSQL
create temporary function getresourcehintattrs(payload string)
returns
    array< struct<name string, attribute string, value string >> language js as '''
var hints = new Set(['preload', 'prefetch']);
var attributes = ['as'];
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
    count(distinct if(script_hint, page, null)) as pages,
    count(distinct page) as total,
    count(distinct if(script_hint, page, null)) / count(distinct page) as pct
from
    (
        select
            _table_suffix as client,
            url as page,
            hint.name in ('prefetch', 'preload')
            and hint.value = 'script' as script_hint
        from `httparchive.pages.2021_07_01_*`
        left join unnest(getresourcehintattrs(payload)) as hint
    )
group by client
