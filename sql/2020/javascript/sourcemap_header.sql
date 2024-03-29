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
    has_sourcemap_header,
    count(distinct page) as pages,
    any_value(total_pages) as total_pages,
    count(distinct page) / any_value(total_pages) as pct_pages,
    count(0) as js_requests,
    sum(count(0)) over (partition by client) as total_js_requests,
    count(0) / sum(count(0)) over (partition by client) as pct_js_requests
from
    (
        select
            client,
            page,
            getheader(json_extract(payload, '$.response.headers'), 'SourceMap')
            is not null as has_sourcemap_header
        from `httparchive.almanac.requests`
        where date = '2020-08-01' and type = 'script'
    )
join
    (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.summary_pages.2020_08_01_*`
        group by client
    ) using (client)
group by client, has_sourcemap_header
order by client, has_sourcemap_header
