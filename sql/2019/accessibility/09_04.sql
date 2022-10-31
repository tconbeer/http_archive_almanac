# standardSQL
# 09_04: % of pages having more than one "main" landmark
create temporary function getmaincount(payload string)
returns int64
language js
as '''
try {
  var $ = JSON.parse(payload);
  var elements = JSON.parse($._element_count);
  if (Array.isArray(elements) || typeof elements != 'object') return 0;
  return elements['main'] || 0;
} catch (e) {
  return 0;
}
'''
;

select
    client,
    main_elements + main_roles as main_landmarks,
    count(distinct page) as pages,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from
    (
        select
            _table_suffix as client, url as page, getmaincount(payload) as main_elements
        from `httparchive.pages.2019_07_01_*`
    )
join
    (
        select
            client,
            page,
            array_length(regexp_extract_all(body, '(?i)role=[\'"]?main')) as main_roles
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    ) using (client, page)
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.pages.2019_07_01_*`
        group by _table_suffix
    ) using (client)
group by client, total, main_landmarks
order by pages / total desc
