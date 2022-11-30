# standardSQL
# Distribution of TLS versions on all TLS-enabled web pages
select
    client,
    tls_version,
    sum(count(0)) over (partition by client) as total_pages,
    count(0) as freq,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select
            client,
            ifnull(
                json_extract_scalar(payload, '$._tls_version'),
                json_extract_scalar(payload, '$._securityDetails.protocol')
            ) as tls_version
        from `httparchive.almanac.requests`
        where date = '2020-08-01' and starts_with(url, 'https') and firsthtml
    )
where tls_version is not null
group by client, tls_version
order by pct desc
