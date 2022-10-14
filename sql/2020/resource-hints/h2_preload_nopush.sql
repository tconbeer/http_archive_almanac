# standardSQL
# 19_15: Count of preload HTTP Headers with nopush attribute set.
CREATE TEMPORARY FUNCTION getLinkHeaders(payload STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS """
try {
  var $ = JSON.parse(payload);
  var headers = $.response.headers;
  var preload=[];

  for (i in headers) {
    if (headers[i].name.toLowerCase() === 'link')
      preload.push(headers[i].value);
    }
  return preload;
} catch (e) {
  return [];
}
""";

select
    client,
    firsthtml,
    count(0) as num_requests,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select client, firsthtml, getlinkheaders(payload) as link_headers
        from `httparchive.almanac.requests`
        where date = '2020-08-01'
    ),
    unnest(link_headers) as link_header
where link_header like '%preload%' and link_header like '%nopush%'
group by client, firsthtml
