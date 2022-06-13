# standardSQL
# CSP on home pages: most commonly used header values
create temporary function getheader(headers string, headername string)
returns string
deterministic
language js
as '''
  const parsed_headers = JSON.parse(headers);
  const matching_headers = parsed_headers.filter(h => h.name.toLowerCase() == headername.toLowerCase());
  if (matching_headers.length > 0) {
    return matching_headers[0].value;
  }
  return null;
'''
;

select
    client,
    csp_header,
    sum(count(0)) over (partition by client) as total_csp_headers,
    count(0) as freq,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select
            client,
            getheader(
                json_extract(payload, '$.response.headers'), 'Content-Security-Policy'
            ) as csp_header
        from `httparchive.almanac.requests`
        where date = '2020-08-01' and firsthtml
    )
where csp_header is not null
group by client, csp_header
order by pct desc
limit 100
