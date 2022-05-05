# standardSQL
# 14_14: Distribution of HTML kilobytes per page
select
    _table_suffix as client,
    round(approx_quantiles(byteshtml, 1000) [offset (100)] / 1024, 2) as p10,
    round(approx_quantiles(byteshtml, 1000) [offset (250)] / 1024, 2) as p25,
    round(approx_quantiles(byteshtml, 1000) [offset (500)] / 1024, 2) as p50,
    round(approx_quantiles(byteshtml, 1000) [offset (750)] / 1024, 2) as p75,
    round(approx_quantiles(byteshtml, 1000) [offset (900)] / 1024, 2) as p90
from `httparchive.summary_pages.2019_07_01_*`
join `httparchive.technologies.2019_07_01_*` using(_table_suffix, url)
where category = 'CMS'
group by client
