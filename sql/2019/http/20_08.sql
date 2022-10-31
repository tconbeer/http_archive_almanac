# standardSQL
# 20.08 - Count of HTTP/2 Sites Grouped By Server
create temporary function getserverheader(payload string)
returns string
language js
as """
  try {
    var $ = JSON.parse(payload);
    var headers = $.response.headers;
    // Find server header
    var st = headers.find(function(e) {
      return e['name'].toLowerCase() === 'server'
    });
    // Remove everything after / in the server header value and return
    return st['value'].split("/")[0];
  } catch (e) {
    return '';
  }
"""
;

select
    client,
    getserverheader(payload) as server_header,
    count(0) as num_pages,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from `httparchive.almanac.requests`
where
    date = '2019-07-01'
    and firsthtml
    and json_extract_scalar(payload, '$._protocol') = 'HTTP/2'
group by client, server_header
order by num_pages desc
