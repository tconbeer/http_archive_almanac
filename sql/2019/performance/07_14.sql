# standardSQL
# 07_14: Percentiles of visually complete metric
select
    percentile,
    _table_suffix as client,
    round(
        approx_quantiles(visualcomplete, 1000)[offset(percentile * 10)] / 1000, 2
    ) as visually_complete
from
    `httparchive.summary_pages.2019_07_01_*`, unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
