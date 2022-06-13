# standardSQL
# 08_06: Cipher suites supporting forward secrecy
select
    _table_suffix as client,
    countif(
        regexp_contains(key_exchange, r'DHE') or protocol = 'TLS 1.3'
    ) as forward_secrecy_count,
    count(0) as total,
    round(
        countif(
            regexp_contains(key_exchange, r'DHE') or protocol = 'TLS 1.3'
        ) * 100 / count(0),
        2
    ) as pct
from
    (
        select
            _table_suffix,
            json_extract(payload, '$._securityDetails.keyExchange') as key_exchange,
            json_extract_scalar(payload, '$._securityDetails.protocol') as protocol
        from `httparchive.requests.2019_07_01_*`
    )
where protocol is not null
group by client
