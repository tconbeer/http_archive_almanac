# standardSQL
# 08_28c: Groupings of "feature-policy" features
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
    split(trim(directive), ' ') [safe_offset(0)] as feature,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from
    `httparchive.almanac.requests`,
    unnest(split(extractheader(payload, 'Feature-Policy'), ';')) as directive
where date = '2019-07-01' and firsthtml
group by client, feature
order by freq / total desc
