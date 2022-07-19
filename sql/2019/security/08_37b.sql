# standardSQL
# 08_37b: SameSite cookie values
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
    normalize_and_casefold(trim(split(directive, '=')[safe_offset(1)])) as value,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from
    `httparchive.almanac.requests`,
    unnest(split(extractheader(payload, 'Set-Cookie'), ';')) as directive
where date = '2019-07-01' and firsthtml and starts_with(trim(directive), 'SameSite')
group by client, value
order by freq / total desc
