# standardSQL
# 20.06 - Number of HTTPS sites not using HTTP/2 which return upgrade HTTP header
# containing h2
create temporary function getupgradeheader(payload string)
returns string
language js
as """
  try {
    var $ = JSON.parse(payload);
    var headers = $.response.headers;
    var st = headers.find(function(e) {
      return e['name'].toLowerCase() === 'upgrade'
    });
    return st['value'];
  } catch (e) {
    return '';
  }
"""
;

select client, firsthtml, count(0) as num_requests
from `httparchive.almanac.requests`
where
    date = '2019-07-01'
    and url like 'https://%'
    and json_extract_scalar(payload, '$._protocol') != 'HTTP/2'
    and getupgradeheader(payload) like '%h2%'
group by client, firsthtml
