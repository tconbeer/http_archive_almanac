# standardSQL
# Distribution of TLS versions by HHTP Version
select
    client,
    http_version_category,
    tls_version,
    count(distinct page) as freq,
    total,
    count(distinct page) / total as pct
from
    (
        select
            client,
            page,
            protocol,
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
            ifnull(tls_version, cert_protocol) as tls_version
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and starts_with(url, 'https') and firsthtml
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2021_07_01_*`
        where starts_with(url, 'https')
        group by client
    ) using (client)
group by client, http_version_category, tls_version, total
order by pct desc
