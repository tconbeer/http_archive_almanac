# standardSQL
# 18_03: Distribution of response size by response format 2021
select
    _table_suffix as client,
    percentile,
    format,
    approx_quantiles(respsize / 1024, 1000)[offset(percentile * 10)] as resp_size
from
    `httparchive.summary_requests.2021_07_01_*`,
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by client, percentile, format
order by format, client, percentile
