# standardSQL
select
    replace(substr(_table_suffix, 0, 10), '_', '') as date,
    if(ends_with(_table_suffix, 'desktop'), 'desktop', 'mobile') as client,
    round(approx_quantiles(bytestotal, 1000)[offset(100)] / 1024, 2) as p10,
    round(approx_quantiles(bytestotal, 1000)[offset(250)] / 1024, 2) as p25,
    round(approx_quantiles(bytestotal, 1000)[offset(500)] / 1024, 2) as p50,
    round(approx_quantiles(bytestotal, 1000)[offset(750)] / 1024, 2) as p75,
    round(approx_quantiles(bytestotal, 1000)[offset(900)] / 1024, 2) as p90
from `httparchive.summary_pages.*`
-- ignore mid-month figures as not always available and throws off chart
where bytestotal > 0 and substr(_table_suffix, 9, 2) = '01'
group by date, client
order by date desc, client
