# standardSQL
# Count of non H2 and H3 Sites Grouped By Server
# As a percentage of all sites
select
    client,
    protocol as http_version,
    # Omit server version
    normalize_and_casefold(
        regexp_extract(resp_server, r'\s*([^/]*)\s*')
    ) as server_header,
    count(0) as num_pages,
    total_pages,
    count(0) / total_pages as pct
from `httparchive.almanac.requests`
join
    (
        select client, count(0) as total_pages
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and firsthtml
        group by client
    )
    using(client)

where
    date = '2021-07-01'
    and firsthtml
    and lower(protocol) != 'http/2'
    and lower(protocol) not like '%quic%'
    and lower(protocol) not like 'h3%'
    and lower(protocol) != 'http/3'
group by client, http_version, server_header, total_pages
having num_pages >= 100
order by num_pages desc
