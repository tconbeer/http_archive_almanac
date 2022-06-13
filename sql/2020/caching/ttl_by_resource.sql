# standardSQL
# TTL by resource type for cacheable (no-store absent) content
select
    _table_suffix as client,
    type as response_type,
    percentile,
    approx_quantiles(expage, 1000) [offset (percentile * 10)] as ttl
from
    `httparchive.summary_requests.2020_08_01_*`,
    unnest( [10, 25, 50, 75, 90]) as percentile
where not regexp_contains(resp_cache_control, r'(?i)no-store') and expage > 0
group by client, response_type, percentile
order by client, response_type, percentile
