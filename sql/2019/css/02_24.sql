# standardSQL
# 02_24: Distribution of stylesheet KB per page
select
    _table_suffix as client,
    round(approx_quantiles(bytescss, 1000) [offset (100)] / 1024, 2) as p10,
    round(approx_quantiles(bytescss, 1000) [offset (250)] / 1024, 2) as p25,
    round(approx_quantiles(bytescss, 1000) [offset (500)] / 1024, 2) as p50,
    round(approx_quantiles(bytescss, 1000) [offset (750)] / 1024, 2) as p75,
    round(approx_quantiles(bytescss, 1000) [offset (900)] / 1024, 2) as p90,
    round(avg(bytescss) / 1024, 2) as avg
from `httparchive.summary_pages.2019_07_01_*`
group by client
