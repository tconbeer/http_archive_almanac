# standardSQL
# 06_09a: distribution of fonts per page
select
    percentile,
    _table_suffix as client,
    approx_quantiles(reqfont, 1000) [offset (percentile * 10)] as fonts
from
    `httparchive.summary_pages.2019_07_01_*`,
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
