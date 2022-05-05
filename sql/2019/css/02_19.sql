# standardSQL
# 02_19: Distribution of stylesheets per page
select
    _table_suffix as client,
    approx_quantiles(reqcss, 1000) [offset (100)] as p10,
    approx_quantiles(reqcss, 1000) [offset (250)] as p25,
    approx_quantiles(reqcss, 1000) [offset (500)] as p50,
    approx_quantiles(reqcss, 1000) [offset (750)] as p75,
    approx_quantiles(reqcss, 1000) [offset (900)] as p90
from `httparchive.summary_pages.2019_07_01_*`
group by client
