# standardSQL
# 01_03: Distribution of JS requests
select
    percentile,
    _table_suffix as client,
    approx_quantiles(reqjs, 1000)[offset(percentile * 10)] as distribution_js_reqs
from
    `httparchive.summary_pages.2019_07_01_*`, unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
