# standardSQL
# The top domains to use immutable Cache-Control directive.
select
    _table_suffix as client,
    net.host(url) as host,
    count(distinct pageid) as pages,
    count(0) as requests,
    sum(count(distinct pageid)) over () as total_pages,
    sum(count(0)) over () as total_requests,
    count(0) / sum(count(0)) over () as pct_requests
from `httparchive.summary_requests.2021_07_01_*`
where regexp_contains(resp_cache_control, r'(?i)immutable')
group by client, domain
order by client, pct_requests desc
limit 200
