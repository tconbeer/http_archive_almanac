# standardSQL
# 10_08: HTTP status codes returned
select
    client,
    status,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from `httparchive.almanac.summary_requests`
where date = '2019-07-01' and firstreq
group by client, status
order by freq / total desc
