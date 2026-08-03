# standardSQL
create temporary function getheader(headers string, headername string)
returns string deterministic
language js
as
    '''
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
    host,
    if(kbytes < 100, floor(kbytes / 5) * 5, 100) as kbytes,
    count(distinct page) as pages,
    any_value(total_pages) as total_pages,
    count(distinct page) / any_value(total_pages) as pct_pages,
    count(0) as js_requests,
    sum(count(0)) over (partition by client, host) as total,
    count(0) / sum(count(0)) over (partition by client, host) as pct
from
    (
        select
            client,
            page,
            if(
                net.host(url) in (
                    select domain
                    from `httparchive.almanac.third_parties`
                    where date = '2020-08-01' and category != 'hosting'
                ),
                'third party',
                'first party'
            ) as host,
            respsize / 1024 as kbytes
        from `httparchive.almanac.requests`
        where
            date = '2020-08-01'
            and type = 'script'
            and getheader(
                json_extract(payload, '$.response.headers'), 'Content-Encoding'
            )
            is null
    )
join
    (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.summary_pages.2020_08_01_*`
        group by client
    ) using (client)
group by client, host, kbytes
order by client, host, kbytes
