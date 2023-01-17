# standardSQL
# Number of HTTPS requests using HTTP/2 which return upgrade HTTP header containing h2
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
    firsthtml,
    protocol as http_version,
    countif(extracthttpheader(response_headers, 'upgrade') like '%h2%') as num_requests,
    count(0) as total,
    countif(extracthttpheader(response_headers, 'upgrade') like '%h2%')
    / count(0) as pct
from `httparchive.almanac.requests`
where date = '2021-07-01' and url like 'https://%' and lower(protocol) = 'http/2'
group by client, firsthtml, http_version
order by pct desc, client, firsthtml, http_version
