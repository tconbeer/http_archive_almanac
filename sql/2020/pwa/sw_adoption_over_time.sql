# standardSQL
# SW adoption over time - based on 2019/11_01b.sql
select yyyymmdd as date, client, num_urls as freq, total_urls as total, pct_urls as pct
from `httparchive.blink_features.usage`
where feature = 'ServiceWorkerControlledPage'
order by date desc, client
