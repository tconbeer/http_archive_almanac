# standardSQL
# Adoption of HTTP/2 by site and requests
select
    client,
    firsthtml,
    json_extract_scalar(payload, '$._protocol') as http_version,
    count(0) as num_requests,
    round(count(0) / sum(count(0)) over (partition by client), 4) as pct
from `httparchive.almanac.requests`
where date = '2020-08-01'
group by client, firsthtml, http_version
order by pct desc
