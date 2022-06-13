# standardSQL
# Number of HTTPS requests using HTTP/2 which return upgrade HTTP header containing h2
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

select
    client,
    firsthtml,
    json_extract_scalar(payload, '$._protocol') as http_version,
    countif(getupgradeheader(payload) like '%h2%') as num_requests,
    count(0) as total
from `httparchive.almanac.requests`
where
    date = '2020-08-01' and url like 'https://%' and json_extract_scalar(
        payload, '$._protocol'
    ) = 'HTTP/2'
group by client, firsthtml, http_version
