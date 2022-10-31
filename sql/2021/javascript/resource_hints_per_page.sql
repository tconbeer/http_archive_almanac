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
    percentile,
    client,
    approx_quantiles(script_hint, 1000)[offset(percentile * 10)] as hints_per_page,
    approx_quantiles(if(script_hint = 0, null, script_hint), 1000 ignore nulls)[
        offset(percentile * 10)
    ] as hints_per_page_with_hints
from
    (
        select
            _table_suffix as client,
            url as page,
            countif(
                hint.name in ('prefetch', 'preload') and hint.value = 'script'
            ) as script_hint
        from `httparchive.pages.2021_07_01_*`
        left join unnest(getresourcehintattrs(payload)) as hint
        group by client, page
    ),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
