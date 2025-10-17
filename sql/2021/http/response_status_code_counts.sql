# standardSQL
# HTTP Status Codes popularity.
select
    client,
    left(cast(status as string), 1) as status_group,
    status,
    count(0) as num_requests,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct,
    array_to_string(array_agg(distinct url limit 5), ' ') as sample_urls
from `httparchive.almanac.requests`
where date = '2021-07-01'
group by client, status
order by num_requests desc, status
limit 1000
