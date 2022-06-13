# standardSQL
# Number of HTTPS requests not using H2 or H3 returning upgrade HTTP header containing
# H2
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
    date = '2020-08-01' and url like 'https://%' and lower(
        json_extract_scalar(payload, '$._protocol')
    ) not like 'http/2' and lower(
        json_extract_scalar(payload, '$._protocol')
    ) not like '%quic%' and lower(
        json_extract_scalar(payload, '$._protocol')
    ) not like 'h3%' and lower(
        json_extract_scalar(payload, '$._protocol')
    ) not like 'http/3%'
group by client, firsthtml, http_version
