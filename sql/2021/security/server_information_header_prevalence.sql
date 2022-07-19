# standardSQL
# Prevalence of server information headers; count by number of hosts.
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
    date,
    client,
    headername,
    count(distinct host) as total_hosts,
    count(
        distinct if(hasheader(response_headers, headername), host, null)
    ) as count_with_header,
    count(distinct if(hasheader(response_headers, headername), host, null))
    / count(distinct host) as pct_with_header
from
    (
        select date, client, net.host(urlshort) as host, response_headers
        from `httparchive.almanac.requests`
        where (date = '2020-08-01' or date = '2021-07-01')
    ),
    unnest(
        ['Server', 'X-Server', 'X-Backend-Server', 'X-Powered-By', 'X-Aspnet-Version']
    ) as headername
group by date, client, headername
order by date, client, count_with_header desc
