# standardSQL
# 08_03: and 08_04: - RSA and ECDSA certificates
create temporary function gethexcert(cert string) returns string as (
    to_hex(
        from_base64(
            replace(
                regexp_replace(cert, '-----(BEGIN|END) CERTIFICATE-----', ''), '\n', ''
            )
        )
    )
)
;

select
    client,
    is_ecdsa,
    is_rsa,
    total,
    round(is_ecdsa * 100 / total, 2) as pct_ecdsa,
    round(is_rsa * 100 / total, 2) as pct_rsa
from
    (
        select
            client,
            countif(
                if(
                    tls13,
                    gethexcert(cert) like '%2a8648ce3d0201%',
                    regexp_contains(key_exchange, r'ECDSA')
                )
            ) as is_ecdsa,
            countif(
                if(
                    tls13,
                    gethexcert(cert) like '%2a864886f70d010101%',
                    regexp_contains(key_exchange, r'RSA')
                )
            ) as is_rsa,
            count(0) as total
        from
            (
                select
                    _table_suffix as client,
                    json_extract_scalar(payload, '$._certificates[0]') as cert,
                    json_extract(
                        payload, '$._securityDetails.keyExchange'
                    ) as key_exchange,
                    json_extract_scalar(payload, '$._securityDetails.protocol')
                    = 'TLS 1.3' as tls13
                from `httparchive.requests.2019_07_01_*`
            )
        where cert is not null
        group by client
    )
