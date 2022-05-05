# standardSQL
# Count of H2 and H3 Sites using Push
select
    client,
    http_version,
    count(distinct if(was_pushed, page, null)) as num_pages_with_push,
    total as total_pages,
    count(distinct if(was_pushed, page, null)) / total as pct
from
    (
        select client, page, protocol as http_version, pushed = '1' as was_pushed
        from `httparchive.almanac.requests`
        where
            date = '2021-07-01' and (
                lower(protocol) = 'http/2' or lower(
                    protocol
                ) like '%quic%' or lower(protocol) like 'h3%' or lower(
                    protocol
                ) = 'http/3'
            )
    )
join
    (
        select client, count(distinct page) as total
        from `httparchive.almanac.requests`
        where date = '2021-07-01'
        group by client
    )
    using(client)
group by client, http_version, total
order by pct desc, client, http_version
