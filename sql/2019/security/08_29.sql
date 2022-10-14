# standardSQL
# 08_29: Groupings of "x-content-type-options" values
CREATE TEMPORARY FUNCTION extractHeader(payload STRING, name STRING)
RETURNS STRING LANGUAGE js AS '''
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
''';

select
    client,
    normalize_and_casefold(extractheader(payload, 'X-Content-Type-Options')) as value,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from `httparchive.almanac.requests`
where date = '2019-07-01' and firsthtml
group by client, value
order by freq / total desc
