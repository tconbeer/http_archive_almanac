# standardSQL
select
    regexp_replace(_table_suffix, r'(\d+)_(\d+)_(\d+).*', r'\1-\2-\3') as date,
    if(ends_with(_table_suffix, 'desktop'), 'desktop', 'mobile') as client,
    approx_quantiles(respheaderssize, 1000)[offset(100)] / 1024 as p10,
    approx_quantiles(respheaderssize, 1000)[offset(250)] / 1024 as p25,
    approx_quantiles(respheaderssize, 1000)[offset(500)] / 1024 as p50,
    approx_quantiles(respheaderssize, 1000)[offset(750)] / 1024 as p75,
    approx_quantiles(respheaderssize, 1000)[offset(900)] / 1024 as p90,
    approx_quantiles(respheaderssize, 1000)[offset(1000)] / 1024 as p100
from `httparchive.summary_requests.*`, unnest([10, 25, 50, 75, 90, 100]) as percentile
where respheaderssize is not null
group by date, client
order by date asc, client
