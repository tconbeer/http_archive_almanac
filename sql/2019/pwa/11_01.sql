# standard SQL
# 11_01: % SW controlled pages
select client, num_urls as freq, total_urls as total, round(pct_urls * 100, 2) as pct
from `httparchive.blink_features.usage`
where yyyymmdd = '20190701' and feature = 'ServiceWorkerControlledPage'
