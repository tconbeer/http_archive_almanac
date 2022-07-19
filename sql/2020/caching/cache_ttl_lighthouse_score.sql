# standardSQL
# Distribution of cache TTL Lighthouse scores
select
    _table_suffix as client,
    json_extract_scalar(report, '$.audits.uses-long-cache-ttl.score') as caching_score,
    count(0) as num_pages,
    sum(count(0)) over (partition by _table_suffix) as total,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct_pages
from `httparchive.lighthouse.2020_08_01_*`
group by client, caching_score
order by client, caching_score asc
