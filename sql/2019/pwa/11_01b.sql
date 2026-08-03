# standardSQL
# 11_01b: SW adoption over time
select
    yyyymmdd as date,
    client,
    num_urls as freq,
    total_urls as total,
    round(pct_urls * 100, 2) as pct
from `httparchive.blink_features.usage`
where feature = 'ServiceWorkerControlledPage'
order by date desc, client
