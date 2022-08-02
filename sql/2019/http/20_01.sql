# standardSQL
# 20.01 - Adoption of HTTP/2 by site and requests
select
    client,
    firsthtml,
    json_extract_scalar(payload, '$._protocol') as http_version,
    count(0) as num_requests,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from `httparchive.almanac.requests`
where date = '2019-07-01'
group by client, firsthtml, http_version
order by client, firsthtml, http_version
