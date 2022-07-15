# standardSQL
# 09_13: % pages with headings out of order
create temporary function includesunorderedheading(headings array < string >)
returns boolean language js as '''
var previous = null;
var seen = new Set();
for (h of headings) {
  h = parseInt(h);
  if (previous && h < previous && !seen.has(h)) {
    return true;
  }
  previous = h;
  seen.add(h);
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
        select client, page, regexp_extract_all(lower(body), '<h([1-6])') as headings
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
where includesunorderedheading(headings)
group by client, total
