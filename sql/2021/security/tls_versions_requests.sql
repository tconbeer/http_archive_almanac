# standardSQL
# Distribution of TLS versions on all TLS-enabled requests
select
    client,
    tls_version,
    sum(count(distinct host)) over (partition by client) as total_https_hosts,
    count(distinct host) as freq,
    count(distinct host) / sum(count(distinct host)) over (partition by client) as pct
from
    (
        select
            client,
            net.host(url) as host,
            ifnull(tls_version, cert_protocol) as tls_version
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and starts_with(url, 'https')
    )
where tls_version is not null
group by client, tls_version
order by client, pct desc
