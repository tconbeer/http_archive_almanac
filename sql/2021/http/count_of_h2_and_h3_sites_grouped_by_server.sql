# standardSQL
# Count of H2 and H3 Sites Grouped By Server
# Note this is a percentage of usage of that server not the total crawl
# I.e. Do Apache servers tend to be on latest features or lagging? What about compared
# to Nginx?
# Does that indicate server software is not upgrade as often (tied to OS?) or defaults
# are old?
select
    client,
    server_header,
    http_version_category,
    http_version,
    count(0) as num_pages,
    sum(count(0)) over (partition by client, server_header) as total,
    count(0) / sum(count(0)) over (partition by client, server_header) as pct
from
    (
        select
            client,
            case
                when lower(protocol) = 'quic' or lower(protocol) like 'h3%'
                then 'HTTP/2+'
                when lower(protocol) = 'http/2' or lower(protocol) = 'http/3'
                then 'HTTP/2+'
                when protocol is null
                then 'Unknown'
                else upper(protocol)
            end as http_version_category,
            case
                when lower(protocol) = 'quic' or lower(protocol) like 'h3%'
                then 'HTTP/3'
                when protocol is null
                then 'Unknown'
                else upper(protocol)
            end as http_version,
            -- Omit server version
            normalize_and_casefold(
                regexp_extract(resp_server, r'\s*([^/]*)\s*')
            ) as server_header
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and firsthtml
    )
group by client, server_header, http_version_category, http_version
qualify total >= 1000
order by num_pages desc, client, server_header
