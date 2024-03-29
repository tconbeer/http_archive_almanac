# standardSQL
# Detailed alt-svc headers
create temporary function getupgradeheader(payload string)
returns string
language js
as """
try {
  var $ = JSON.parse(payload);
  var headers = $.response.headers;
  return headers.find(h => h.name.toLowerCase() === 'alt-svc').value.trim();
} catch (e) {
  return '';
}
"""
;

select
    client,
    firsthtml,
    json_extract_scalar(payload, '$._protocol') as protocol,
    if(url like 'https://%', 'https', 'http') as http_or_https,
    normalize_and_casefold(getupgradeheader(payload)) as upgrade,
    count(0) as num_requests,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from `httparchive.almanac.requests`
where date = '2020-08-01'
group by client, firsthtml, protocol, http_or_https, upgrade
having num_requests >= 100
order by num_requests desc
