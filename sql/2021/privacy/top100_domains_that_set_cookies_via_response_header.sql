# standardSQL
# Top100 domains that set cookies via response header
CREATE TEMPORARY FUNCTION cookieNames(headers STRING)
RETURNS ARRAY<STRING> DETERMINISTIC
LANGUAGE js AS '''
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
''';

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
            net.reg_domain(url) as domain,
            cookienames(response_headers) as cookie_names,
            count(distinct page) over (partition by client) as websites_per_client
        from `httparchive.almanac.requests`
        where date = '2021-07-01'
        group by client, page, url, response_headers
    ),

    cookies as (
        select
            client,
            domain,
            count(distinct page) as websites_count,
            websites_per_client,
            count(distinct page) / websites_per_client as pct_websites
        from request_headers, unnest(cookie_names) as cookie
        where cookie is not null and cookie != ''
        group by client, domain, websites_per_client
    )

select
    client,
    whotracksme.category,
    cookies.domain,
    websites_count,
    websites_per_client,
    pct_websites
from cookies
join whotracksme on net.host(cookies.domain) = whotracksme.domain
order by pct_websites desc, client
limit 100
