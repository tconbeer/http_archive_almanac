# standardSQL
# 08_02: Distribution of issuers
select
    client,
    issuer,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from
    (
        select
            _table_suffix as client,
            json_extract_scalar(payload, '$._securityDetails.issuer') as issuer
        from `httparchive.requests.2019_07_01_*`
    )
where issuer is not null
group by client, issuer
order by freq / total desc
