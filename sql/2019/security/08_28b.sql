# standardSQL
# 08_28b: Groupings of "feature-policy" directives
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
    split(trim(directive), ' ')[safe_offset(0)] as feature,
    split(trim(directive), ' ')[safe_offset(1)] as rule,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from
    `httparchive.almanac.requests`,
    unnest(split(extractheader(payload, 'Feature-Policy'), ';')) as directive
where date = '2019-07-01' and firsthtml
group by client, feature, rule
order by freq / total desc
