# standardSQL
# 08_39b: SRI header
create temporary function extractheader(payload string, name string)
returns string
language js
as
    '''
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
    countif(requires_sri) as pages,
    count(0) as total,
    round(countif(requires_sri) * 100 / count(0), 2) as pct
from
    (
        select
            client,
            regexp_contains(
                extractheader(payload, 'Content-Security-Policy'), '(?i)require-sri-for'
            ) as requires_sri
        from `httparchive.almanac.requests`
        where date = '2019-07-01' and firsthtml
    )
group by client
