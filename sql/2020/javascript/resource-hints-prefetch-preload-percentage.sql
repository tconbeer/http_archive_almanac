# standardSQL
CREATE TEMPORARY FUNCTION getResourceHintAttrs(payload STRING)
RETURNS ARRAY<STRUCT<name STRING, attribute STRING, value STRING>>
LANGUAGE js AS '''
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
''';

select
    client,
    count(distinct if(prefetch_hint, page, null)) as prefetch_pages,
    count(distinct page) as total,
    count(distinct if(prefetch_hint, page, null))
    / count(distinct page) as prefetch_pct,
    count(distinct if(preload_hint, page, null)) as preload_pages,
    count(distinct if(preload_hint, page, null)) / count(distinct page) as preload_pct
from
    (
        select
            _table_suffix as client,
            url as page,
            hint.name = 'prefetch' and hint.value = 'script' as prefetch_hint,
            hint.name = 'preload' and hint.value = 'script' as preload_hint
        from `httparchive.pages.2020_08_01_*`
        left join unnest(getresourcehintattrs(payload)) as hint
    )
group by client
