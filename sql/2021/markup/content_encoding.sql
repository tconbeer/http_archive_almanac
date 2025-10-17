# standardSQL
# type of content_encoding
select
    client,
    mimetype,
    resp_content_encoding as content_encoding,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from `httparchive.almanac.requests`
where firsthtml and date = '2021-07-01'
group by client, mimetype, content_encoding
order by pct desc, client, freq desc
