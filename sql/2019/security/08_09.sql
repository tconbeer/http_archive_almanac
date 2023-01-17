# standardSQL
# 08_09 Legacy cipher suites
# Distribution of all ciphers
select
    _table_suffix as client,
    json_extract_scalar(payload, '$._securityDetails.cipher') as cipher,
    count(0) as cipher_count,
    sum(count(0)) over (partition by _table_suffix) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by _table_suffix), 2) as pct
from `httparchive.requests.2019_07_01_*`
group by client, cipher
having cipher is not null
order by cipher_count desc
