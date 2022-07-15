# standardSQL
# 17_23: Percentage of responses with pre-check directive
select
    _table_suffix as client,
    _cdn_provider as cdn,
    countif(lower(resp_cache_control) like '%pre-check%') as freq,
    count(0) as total,
    round(
        countif(lower(resp_cache_control) like '%pre-check%') * 100 / count(0), 2
    ) as pct
from `httparchive.summary_requests.2019_07_01_*`
group by client, cdn
order by total desc
