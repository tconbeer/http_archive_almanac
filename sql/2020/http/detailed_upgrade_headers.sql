# standardSQL
# Detailed upgrade headers for 20.04, 20.05 and 20.06
select
    client,
    firsthtml,
    json_extract_scalar(payload, '$._protocol') as protocol,
    if(url like 'https://%', 'https', 'http') as http_or_https,
    regexp_extract(
        regexp_extract(respotherheaders, r'(?is)Upgrade = (.*)'),
        r'(?im)^([^=]*?)(?:, [a-z-]+ = .*)'
    ) is not null as upgrade,
    count(0) as num_requests,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from `httparchive.almanac.requests`
where date = '2020-08-01'
group by client, firsthtml, protocol, http_or_https, upgrade
having num_requests >= 100
order by num_requests desc
