# standardSQL
# Detailed alt-svc headers per page
create temporary function extracthttpheader(httpheaders string, header string)
returns string
language js
as
    """
try {
  var headers = JSON.parse(HTTPheaders);

  // Filter by header name (which is case insensitive)
  // If multiple headers it's the same as comma separated
  return headers.filter(h => h.name.toLowerCase() == header.toLowerCase()).map(h => h.value).join(",");

} catch (e) {
  return "";
}
"""
;

select
    client,
    protocol,
    if(url like 'https://%', 'https', 'http') as http_or_https,
    normalize_and_casefold(extracthttpheader(response_headers, 'alt-svc')) as altsvc,
    count(0) as num_pages,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from `httparchive.almanac.requests`
where date = '2021-07-01' and firsthtml
group by client, protocol, http_or_https, altsvc
qualify  -- Use QUALIFY rather than HAVING to allow total column to work
    num_pages >= 100
order by num_pages desc
