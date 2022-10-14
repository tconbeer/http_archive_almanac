# standardSQL
# 20.13 Count of preload HTTP Headers with nopush attribute set. Once off stat for
# last crawl
CREATE TEMPORARY FUNCTION getLinkHeaders(payload STRING)
RETURNS ARRAY<STRING>
LANGUAGE js AS """
  var $ = JSON.parse(payload);
  var headers = $.response.headers;
  var preload=[];

  for (i in headers) {
      if (headers[i].name.toLowerCase() === 'link')
        preload.push(headers[i].value);
  }
  return preload;

""";

select
    client,
    firsthtml,
    count(0) as num_requests,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from
    (
        select client, firsthtml, getlinkheaders(payload) as link_headers
        from `httparchive.almanac.requests`
        where date = '2019-07-01'
    )
cross join unnest(link_headers) as link_header
where link_header like '%preload%' and link_header like '%nopush%'
group by client, firsthtml
