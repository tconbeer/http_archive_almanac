# standardSQL
# Sites with more than 1000 non-2xx status codes, or more than 500KiB
select
    client,
    status,
    page,
    count(0) as number,
    sum(respheaderssize) / 1024 as respheadersizekib,
    sum(respbodysize) / 1024 as respbodysizekib
from `httparchive.almanac.requests`
where date = '2021-07-01' and (status < 200 or status > 299)
group by client, status, page
having number > 1000 or respheadersizekib > 500
order by number desc, respheadersizekib desc
