# standardSQL
# Distribution of CA issuers for all pages
select
    client,
    issuer,
    sum(count(0)) over (partition by client) as total_pages,
    count(0) as freq,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select
            client,
            net.host(url) as request_host,
            any_value(
                json_extract_scalar(payload, '$._securityDetails.issuer')
            ) as issuer
        from `httparchive.almanac.requests`
        where
            date = '2020-08-01' and net.host(page) = net.host(url) and
            json_extract_scalar(payload, '$._securityDetails.issuer') is not null
        group by client, request_host
    )
group by client, issuer
order by pct desc
