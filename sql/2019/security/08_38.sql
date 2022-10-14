# standardSQL
# 08_38: Cookie prefixes
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
    prefix,
    count(distinct page) as pages,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from
    `httparchive.almanac.requests`,
    unnest(split(extractheader(payload, 'Set-Cookie'), ';')) as directive,
    unnest(regexp_extract_all(directive, '(__Host-|__Secure-)')) as prefix
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (client)
where date = '2019-07-01' and firsthtml and prefix is not null
group by client, total, prefix
order by pages / total desc
