# standardSQL
# CSP on home pages: most prevalent allowed hosts
create temporary function getheader(headers string, headername string)
returns string deterministic
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

with
    totals as (
        select client, count(0) as total
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and firsthtml
        group by client
    )

select
    client,
    csp_allowed_host,
    total as total_pages,
    count(distinct page) as freq,
    count(distinct page) / min(total) as pct
from
    (
        select
            client,
            page,
            getheader(response_headers, 'Content-Security-Policy') as csp_header
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and firsthtml
    )
join
    totals using (client),
    unnest(
        regexp_extract_all(csp_header, r'(?i)(https*://[^\s;]+)[\s;]')
    ) as csp_allowed_host
where csp_header is not null
group by client, total, csp_allowed_host
order by pct desc
limit 100
