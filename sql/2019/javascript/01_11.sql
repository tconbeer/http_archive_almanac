# standardSQL
# 01_11: Distribution of JS bytes for top JS frameworks
select
    app,
    _table_suffix as client,
    count(distinct url) as freq,
    approx_quantiles(round(bytesjs / 1024), 1000)[offset(100)] as p10_js_kbytes,
    approx_quantiles(round(bytesjs / 1024), 1000)[offset(250)] as p25_js_kbytes,
    approx_quantiles(round(bytesjs / 1024), 1000)[offset(500)] as median_js_kbytes,
    approx_quantiles(round(bytesjs / 1024), 1000)[offset(750)] as p75_js_kbytes,
    approx_quantiles(round(bytesjs / 1024), 1000)[offset(900)] as p90_js_kbytes
from `httparchive.summary_pages.2019_07_01_*`
join `httparchive.technologies.2019_07_01_*` using (_table_suffix, url)
where category = 'JavaScript Frameworks'
group by app, client
order by freq desc
