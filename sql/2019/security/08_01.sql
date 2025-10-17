# standardSQL
# 08_01: Distribution of TLS versions
select
    client,
    tls_version,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from
    (
        select
            _table_suffix as client,
            json_extract_scalar(payload, '$._tls_version') as tls_version
        from `httparchive.requests.2019_07_01_*`
    )
where tls_version is not null
group by client, tls_version
order by freq / total desc
