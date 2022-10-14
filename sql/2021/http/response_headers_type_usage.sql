# standardSQL
# List of the top used response headers
CREATE TEMPORARY FUNCTION extractHTTPHeaders(HTTPheaders STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS """
try {
  var headers = JSON.parse(HTTPheaders);

  // Filter by header name (which is case insensitive)
  // If multiple headers it's the same as comma separated
  return headers.map(h => h.name.toLowerCase());

} catch (e) {
  return "";
}
""";

select client, header, count(0) as num_requests, total, count(0) / total as pct
from
    `httparchive.almanac.requests`,
    unnest(extracthttpheaders(response_headers)) as header
join
    (
        select client, count(0) as total
        from `httparchive.almanac.requests`
        group by client
    ) using (client)
where date = '2021-07-01'
group by client, header, total
order by pct desc, client
limit 1000
