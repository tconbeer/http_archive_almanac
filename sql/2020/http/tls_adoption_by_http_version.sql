# standardSQL
# Distribution of TLS versions by HHTP Version
select
    client,
    protocol,
    tls_version,
    count(distinct page) as freq,
    total,
    count(distinct page) / total as pct
from
    (
        select
            client,
            page,
            if(
                json_extract_scalar(payload, '$._protocol') in (
                    'http/0.9',
                    'http/1.0',
                    'http/1.1',
                    'HTTP/2',
                    'QUIC',
                    'http/2+quic/46',
                    'HTTP/3'
                ),
                json_extract_scalar(payload, '$._protocol'),
                'other'
            ) as protocol,
            ifnull(
                json_extract_scalar(payload, '$._tls_version'),
                json_extract_scalar(payload, '$._securityDetails.protocol')
            ) as tls_version
        from `httparchive.almanac.requests`
        where date = '2020-08-01' and starts_with(url, 'https') and firsthtml
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        where starts_with(url, 'https')
        group by client
    )
    using
    (client)
group by client, protocol, tls_version, total
order by pct desc
