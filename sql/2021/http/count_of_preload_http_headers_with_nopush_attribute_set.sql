# standardSQL
# Count of preload HTTP Headers with nopush attribute set. Once off stat for last crawl
CREATE TEMPORARY FUNCTION extractHTTPHeaders(HTTPheaders STRING, header STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS """
try {
  var headers = JSON.parse(HTTPheaders);

  // Filter by header name (which is case insensitive) and return values
  return headers.filter(h => h.name.toLowerCase() == header.toLowerCase()).map(h => h.value);

} catch (e) {
  return [];
}
""";

select
    client,
    countif(link_header like '%nopush%') as num_nopush,
    count(0) as total_preload_http_headers,
    countif(link_header like '%nopush%') / count(0) as pct_nopush,
    countif(link_header not like '%nopush%') / count(0) as pct_push
from
    (
        select client, extracthttpheaders(response_headers, 'link') as link_headers
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and firsthtml
    ),
    unnest(link_headers) as link_header
where link_header like '%preload%'
group by client
order by client
