# standardSQL
# static dynamic compression
select
    client,
    resp_content_encoding,
    if(
        lower(resp_cache_control) like '%no-store%', 'dynamic', 'static'
    ) as static_or_dynamic,
    count(0) as num_requests,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from `httparchive.almanac.requests`
where date = '2020-08-01'
group by client, resp_content_encoding, static_or_dynamic
order by num_requests desc
