# standardSQL
# Home page usage of HTTPS
select
    client,
    starts_with(page, 'https') as https,
    count(0) as pages,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from `httparchive.almanac.requests`
where date = '2021-07-01' and firsthtml
group by client, https
