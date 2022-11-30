# standardSQL
# Distribution of TLS versions on all TLS-enabled web pages
select
    client,
    tls_version,
    sum(count(0)) over (partition by client) as total_https_pages,
    count(0) as freq,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select client, ifnull(tls_version, cert_protocol) as tls_version
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and starts_with(url, 'https') and firsthtml
    )
where tls_version is not null
group by client, tls_version
order by pct desc
