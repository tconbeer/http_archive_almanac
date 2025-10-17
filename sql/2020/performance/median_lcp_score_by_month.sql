# standardSQL
# Median of Largest contentful paint 75% score by month
select
    device,
    date,
    approx_quantiles(p75_lcp, 1000 respect nulls)[offset(500)] as median_p75_lcp
from `chrome-ux-report.materialized.device_summary`
where date >= '2019-09-01' and date <= '2020-08-01' and device in ('desktop', 'phone')
group by device, date
