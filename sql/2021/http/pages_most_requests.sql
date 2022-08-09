# standardSQL
# Pages loading most number of requests
select
    client,
    page,
    count(0) as numberofrequests,
    sum(respheaderssize) / 1024 as responseheadersizekib,
    sum(respbodysize) / 1024 as responsebodysizekib
from `httparchive.almanac.requests`
where date = '2021-07-01'
group by client, page
order by count(0) desc
limit 100
