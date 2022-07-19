# standardSQL
# Distribution of CA issuers for all requests
select
    client,
    issuer,
    sum(count(0)) over (partition by client) as total_requests,
    count(0) as freq,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select
            client, json_extract_scalar(payload, '$._securityDetails.issuer') as issuer
        from `httparchive.almanac.requests`
        where date = '2020-08-01'
    )
where issuer is not null
group by client, issuer
order by pct desc
