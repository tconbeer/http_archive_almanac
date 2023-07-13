# standardSQL
# type of content_encoding
select
    client,
    mimetype,
    resp_content_encoding,
    count(0) as num_requests,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from `httparchive.almanac.requests`
where date = '2020-08-01'
group by client, mimetype, resp_content_encoding
having num_requests > 1000
order by num_requests desc
