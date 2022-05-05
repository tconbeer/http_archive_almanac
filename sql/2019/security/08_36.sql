# standardSQL
# 08_36: Secure cookies
create temporary function extractheader(payload string, name string)
returns string language js
as '''
try {
  var $ = JSON.parse(payload);
  var header = $._headers.response.find(h => h.toLowerCase().startsWith(name.toLowerCase()));
  if (!header) {
    return null;
  }
  return header.substr(header.indexOf(':') + 1).trim();
} catch (e) {
  return null;
}
'''
;

select
    client,
    count(distinct page) as pages,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from
    `httparchive.almanac.requests`,
    unnest(split(extractheader(payload, 'Set-Cookie'), ';')) as directive
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    )
    using(client)
where date = '2019-07-01' and firsthtml and trim(directive) = 'Secure'
group by client, total
order by pages / total desc
