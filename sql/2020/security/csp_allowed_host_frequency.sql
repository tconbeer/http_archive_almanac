# standardSQL
# CSP on home pages: most prevalent allowed hosts
CREATE TEMPORARY FUNCTION getHeader(headers STRING, headername STRING)
RETURNS STRING
DETERMINISTIC
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
    csp_allowed_host,
    sum(count(distinct page)) over (partition by client) as total_pages,
    count(distinct page) as freq,
    count(distinct page) / sum(count(distinct page)) over (partition by client) as pct
from
    (
        select
            client,
            page,
            getheader(
                json_extract(payload, '$.response.headers'), 'Content-Security-Policy'
            ) as csp_header
        from `httparchive.almanac.requests`
        where date = '2020-08-01' and firsthtml
    ),
    unnest(
        regexp_extract_all(csp_header, r'(?i)(https*://[^\s;]+)[\s;]')
    ) as csp_allowed_host
where csp_header is not null
group by client, csp_allowed_host
order by pct desc
limit 100
