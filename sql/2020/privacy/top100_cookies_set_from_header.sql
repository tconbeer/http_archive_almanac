# standardSQL
# Top100 popular cookies and their origins
create temporary function cookienames(headers string)
returns array<string> deterministic
language js
as '''
try {
  var headers = JSON.parse(headers);
  let cookies = headers.filter(h => h.name.match(/^set-cookie$/i));
  cookieNames = cookies.map(h => {
    name = h.value.split('=')[0]
    return name;
  })
  return cookieNames;
} catch (e) {
  return null;
}
'''
;

with
    request_headers as (
        select
            _table_suffix as client,
            page,
            net.reg_domain(url) as request,
            cookienames(json_extract(payload, '$.response.headers')) as cookie_names,
            count(0) over (partition by _table_suffix) as websites_per_client
        from `httparchive.requests.2020_08_01_*`
        group by client, page, url, payload
    ),

    cookies as (
        select
            client,
            request,
            cookie,
            count(distinct page) as websites_count,
            count(distinct page) / any_value(websites_per_client) as pct_websites
        from request_headers, unnest(cookie_names) as cookie
        where cookie is not null and cookie != ''
        group by client, request, cookie
    )

select client, request, cookie, websites_count, pct_websites
from cookies
order by websites_count desc
limit 100
