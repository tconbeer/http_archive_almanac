# standardSQL
# CORP usage: most commonly used header values
CREATE TEMPORARY FUNCTION getHeader(headers STRING, headername STRING)
RETURNS STRING DETERMINISTIC
LANGUAGE js AS '''
  const parsed_headers = JSON.parse(headers);
  const matching_headers = parsed_headers.filter(h => h.name.toLowerCase() == headername.toLowerCase());
  if (matching_headers.length > 0) {
    return matching_headers[0].value;
  }
  return null;
''';

select
    client,
    corp_header,
    sum(count(distinct host)) over (partition by client) as total_corp_headers,
    count(distinct host) as freq,
    count(distinct host) / sum(count(distinct host)) over (partition by client) as pct
from
    (
        select
            client,
            net.host(urlshort) as host,
            getheader(response_headers, 'Cross-Origin-Resource-Policy') as corp_header
        from `httparchive.almanac.requests`
        where date = '2021-07-01'
    )
where corp_header is not null
group by client, corp_header
order by pct desc
limit 100
