# standardSQL
# 08_07: Autheticated cipher suites
select
    _table_suffix as client,
    countif(regexp_contains(cipher, r'GCM|CCM|POLY1305')) as authenticated_cipher_count,
    count(0) as total,
    round(
        countif(regexp_contains(cipher, r'GCM|CCM|POLY1305')) * 100 / count(0), 2
    ) as pct
from
    (
        select
            _table_suffix, json_extract(payload, '$._securityDetails.cipher') as cipher
        from `httparchive.requests.2019_07_01_*`
    )
where cipher is not null
group by client
