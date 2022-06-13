# standardSQL
# Number of HTTPS requests not using H2 or H3 returning upgrade HTTP header containing
# H2
create temporary function extracthttpheader(httpheaders string, header string)
returns string language js
as """
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
    countif(extracthttpheader(response_headers, 'upgrade') like '%h2%') as num_requests,
    count(0) as total
from `httparchive.almanac.requests`
where
    date = '2021-07-01' and url like 'https://%' and lower(
        protocol
    ) != 'http/2' and lower(protocol) not like '%quic%' and lower(
        protocol
    ) not like 'h3%' and lower(protocol) != 'http/3'
group by client, firsthtml
