# standardSQL
# Distribution of all ciphers for all requests
select
    client,
    cipher,
    sum(count(0)) over (partition by client) as total_requests,
    count(0) as freq,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select
            client, json_extract_scalar(payload, '$._securityDetails.cipher') as cipher
        from `httparchive.almanac.requests`
        where date = '2020-08-01'
    )
where cipher is not null
group by client, cipher
order by pct desc
