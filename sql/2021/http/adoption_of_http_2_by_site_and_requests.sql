# standardSQL
# Adoption of HTTP/2 by site and requests
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
    protocol,
    count(0) as num_requests,
    sum(count(0)) over (partition by client) as total_req,
    count(0) / sum(count(0)) over (partition by client) as num_requests_pct,
    countif(firsthtml) as num_pages,
    sum(countif(firsthtml)) over (partition by client) as total_pages,
    countif(firsthtml) / sum(
        countif(firsthtml)
    ) over (partition by client) as num_pages_pct
from `httparchive.almanac.requests`
where date = '2021-07-01'
group by client, protocol
order by client, num_requests_pct desc
