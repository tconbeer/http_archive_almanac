# standardSQL
# 09_02: % of pages having minimum set of accessible elements
# Compliant pages have: header, footer, nav, and main (or [role=main]) elements
create temporary function getcompliantelements(payload string)
returns array
< string
> language js as '''
try {
  var $ = JSON.parse(payload);
  var elements = JSON.parse($._element_count);
  if (Array.isArray(elements) || typeof elements != 'object') return [];
  var compliantElements = new Set(['header', 'footer', 'nav', 'main']);
  return Object.keys(elements).filter(e => compliantElements.has(e));
} catch (e) {
  return [];
}
'''
;

select
    client,
    count(distinct page) as pages,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from
    (
        select
            _table_suffix as client,
            url as page,
            getcompliantelements(payload) as compliant_elements
        from `httparchive.pages.2019_07_01_*`
    )
join
    (
        select
            client, page, regexp_contains(body, '(?i)role=[\'"]?main') as has_role_main
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    )
    using
    (client, page)
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.pages.2019_07_01_*`
        group by _table_suffix
    )
    using(client)
where
    'header' in unnest(compliant_elements)
    and 'footer' in unnest(compliant_elements)
    and 'nav' in unnest(compliant_elements)
    and ('main' in unnest(compliant_elements) or has_role_main)
group by client, total
