# standardSQL
# 09_01b: % of pages having any heading
create temporary function hasheading(payload string)
returns boolean
language js
as
    '''
try {
  var $ = JSON.parse(payload);
  var elements = JSON.parse($._element_count);
  if (Array.isArray(elements) || typeof elements != 'object') {
    return false;
  }

  return (elements.h1 || elements.h2 || elements.h3 || elements.h4 || elements.h5 || elements.h6 || 0) > 0;
} catch (e) {
  return false;
}
'''
;

select
    client,
    count(0) as total_pages,
    countif(has_heading) as total_with_heading,
    round(countif(has_heading) * 100 / count(0), 2) as pct_with_heading
from
    (
        select _table_suffix as client, hasheading(payload) as has_heading
        from `httparchive.pages.2019_07_01_*`
    )
group by client
