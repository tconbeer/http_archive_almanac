# standardSQL
# compression_formats.sql : What compression formats are being used (gzip, brotli, etc)
select
    client,
    resp_content_encoding,
    count(0) as num_requests,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from `httparchive.almanac.requests`
where date = '2021-07-01'
group by client, resp_content_encoding
order by num_requests desc
