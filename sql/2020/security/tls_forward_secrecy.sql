# standardSQL
# Cipher suites supporting forward secrecy for all requests
select
    client,
    count(0) as total_requests,
    countif(
        regexp_contains(key_exchange, r'(?i)DHE') or protocol = 'TLS 1.3'
    ) as forward_secrecy_count,
    countif(regexp_contains(key_exchange, r'(?i)DHE') or protocol = 'TLS 1.3') / count(
        0
    ) as pct
from
    (
        select
            client,
            json_extract(payload, '$._securityDetails.keyExchange') as key_exchange,
            json_extract_scalar(payload, '$._securityDetails.protocol') as protocol
        from `httparchive.almanac.requests`
        where date = '2020-08-01'
    )
where protocol is not null
group by client
order by client, pct desc
