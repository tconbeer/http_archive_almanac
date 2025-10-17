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
    whotracksme as (
        select domain, category, tracker
        from `httparchive.almanac.whotracksme`
        where date = '2021-07-01'
    ),

    request_headers as (
        select
            client,
            page,
            net.reg_domain(url) as request,
            cookienames(response_headers) as cookie_names,
            count(distinct page) over (partition by client) as websites_per_client
        from `httparchive.almanac.requests`
        group by client, page, url, response_headers
    ),

    cookies as (
        select
            client,
            request,
            cookie,
            count(distinct page) as websites_count,
            websites_per_client,
            count(distinct page) / websites_per_client as pct_websites
        from request_headers, unnest(cookie_names) as cookie
        where cookie is not null and cookie != ''
        group by client, request, cookie, websites_per_client
    )

select
    client,
    whotracksme.category,
    request,
    cookie,
    cookie || ' - ' || request as cookie_and_request,
    websites_count,
    websites_per_client,
    pct_websites
from cookies
left join whotracksme on net.host(request) = domain
order by pct_websites desc, client
limit 1000
