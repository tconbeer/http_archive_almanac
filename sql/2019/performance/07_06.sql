# standardSQL
# 07_06: % offline websites
select
    countif(offlinedensity > 0) as freq,
    count(0) as total,
    round(countif(offlinedensity > 0) * 100 / count(0), 2) as pct
from `chrome-ux-report.materialized.metrics_summary`
where date = '2019-07-01'
