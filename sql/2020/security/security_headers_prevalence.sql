# standardSQL
# Prevalence of security headers set in a first-party context; count by number of
# hosts.
create temporary function hasheader(headers string, headername string)
returns bool
deterministic
language js
as '''
  const parsed_headers = JSON.parse(headers);
  const matching_headers = parsed_headers.filter(h => h.name.toLowerCase() == headername.toLowerCase());
  return matching_headers.length > 0;
'''
;

select
    date,
    client,
    headername,
    count(distinct host) as total_hosts,
    count(distinct if(hasheader(headers, headername), host, null)) as num_with_header,
    count(distinct if(hasheader(headers, headername), host, null)) / count(
        distinct host
    ) as pct_with_header
from
    (
        select
            date,
            client,
            net.host(urlshort) as host,
            json_extract(payload, '$.response.headers') as headers
        from `httparchive.almanac.requests`
        where
            (date = '2020-08-01' or date = '2019-07-01') and
            net.host(urlshort) = net.host(page)
    ),
    unnest(
        [
            'Content-Security-Policy',
            'Cross-Origin-Embedder-Policy',
            'Cross-Origin-Opener-Policy',
            'Cross-Origin-Resource-Policy',
            'Expect-CT',
            'Feature-Policy',
            'Permissions-Policy',
            'Referrer-Policy',
            'Report-To',
            'Strict-Transport-Security',
            'X-Content-Type-Options',
            'X-Frame-Options',
            'X-XSS-Protection'
        ]
    ) as headername
group by date, client, headername
order by date, client, headername
