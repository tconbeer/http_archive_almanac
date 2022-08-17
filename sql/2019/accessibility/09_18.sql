# standardSQL
# 09_18: % of pages having a table caption/thead
# Caveat: This does not necessarily enforce that the element is within the table.
create temporary function gettableelements(payload string)
returns array
< string
> language js as '''
try {
  var $ = JSON.parse(payload);
  var elements = JSON.parse($._element_count);
  if (Array.isArray(elements) || typeof elements != 'object') return [];
  var tableElements = new Set(['table', 'caption', 'thead']);
  return Object.keys(elements).filter(e => tableElements.has(e));
} catch (e) {
  return [];
}
'''
;

select
    client,
    countif('caption' in unnest(table_elements)) as caption_pages,
    countif('thead' in unnest(table_elements)) as thead_pages,
    count(0) as table_pages,
    round(
        countif('caption' in unnest(table_elements)) * 100 / count(0), 2
    ) as pct_caption,
    round(countif('thead' in unnest(table_elements)) * 100 / count(0), 2) as pct_thead
from
    (
        select _table_suffix as client, gettableelements(payload) as table_elements
        from `httparchive.pages.2019_07_01_*`
    )
where 'table' in unnest(table_elements)
group by client
