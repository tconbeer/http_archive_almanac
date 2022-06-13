# standardSQL
# 09_11: % pages with headings that skip levels
create temporary function includesskippedheading(headings array < string >)
returns boolean language js
as '''
var previous = null;
for (h of headings) {
  h = parseInt(h);
  if (previous && h > previous && (h - previous) > 1) {
    return true;
  }
  previous = h;
}
return false;
'''
;

select
    client,
    count(distinct page) as pages,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from
    (
        select client, page, regexp_extract_all(body, '(?i)</h([1-6])>') as headings
        from `httparchive.almanac.summary_response_bodies`
        where date = '2019-07-01' and firsthtml
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.pages.2019_07_01_*`
        group by _table_suffix
    )
    using(client)
where includesskippedheading(headings)
group by client, total
