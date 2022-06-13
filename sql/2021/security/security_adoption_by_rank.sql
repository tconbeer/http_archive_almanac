# standardSQL
# Prevalence of security headers set in a first-party context; per rank grouping (1k,
# 10k, 100k, 1m, all)
create temporary function hasheader(headers string, headername string)
returns bool deterministic
language js
as '''
  const parsed_headers = JSON.parse(headers);
  const matching_headers = parsed_headers.filter(h => h.name.toLowerCase() == headername.toLowerCase());
  return matching_headers.length > 0;
'''
;

select
    client,
    headername,
    rank_grouping,
    count(distinct net.host(urlshort)) as total_hosts,
    count(
        distinct if(hasheader(response_headers, headername), net.host(urlshort), null)
    ) as num_with_header,
    count(
        distinct if(hasheader(response_headers, headername), net.host(urlshort), null)
    ) / count(distinct net.host(urlshort)) as pct_with_header
from
    `httparchive.almanac.requests`,
    unnest(
        [
            'Content-Security-Policy',
            'Content-Security-Policy-Report-Only',
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
    ) as headername,
    unnest( [1000, 10000, 100000, 1000000, 10000000]) as rank_grouping
where
    date = '2021-07-01' and rank <= rank_grouping and net.host(urlshort) = net.host(
        page
    )
group by client, headername, rank_grouping
order by client, headername, rank_grouping
