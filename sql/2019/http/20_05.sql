# standardSQL
# 20.05 - Number of HTTPS sites using HTTP/2 which return upgrade HTTP header
# containing h2
CREATE TEMPORARY FUNCTION getUpgradeHeader(payload STRING)
RETURNS STRING
LANGUAGE js AS """
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
""";

select client, firsthtml, count(0) as num_requests
from `httparchive.almanac.requests`
where
    date = '2019-07-01'
    and url like 'https://%'
    and json_extract_scalar(payload, '$._protocol') = 'HTTP/2'
    and getupgradeheader(payload) like '%h2%'
group by client, firsthtml
