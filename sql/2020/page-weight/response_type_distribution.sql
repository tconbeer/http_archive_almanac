# standardSQL
# 18_04: Distribution of response size by response type
select
    _table_suffix as client,
    percentile,
    type,
    approx_quantiles(respsize / 1024, 1000)[offset(percentile * 10)] as resp_size
from
    `httparchive.summary_requests.2020_08_01_*`,
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by client, percentile, type
order by client, type, percentile
