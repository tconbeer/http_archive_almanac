# standardSQL
# 20.04a_5a_6a - Detailed upgrade headers for 20.04, 20.05 and 20.06
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

select
    client,
    firsthtml,
    json_extract_scalar(payload, '$._protocol') as protocol,
    if(url like 'https://%', 'https', 'http') as http_or_https,
    getupgradeheader(payload) as upgrade,
    count(0) as num_requests
from `httparchive.almanac.requests`
where date = '2019-07-01'
group by client, firsthtml, protocol, http_or_https, upgrade
