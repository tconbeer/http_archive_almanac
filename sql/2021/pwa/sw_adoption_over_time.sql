# standardSQL
# SW adoption over time
select distinct
    regexp_replace(yyyymmdd, r'(\d{4})(\d{2})(\d{2})', r'\1-\2\-3') as date,
    client,
    num_urls as freq,
    total_urls as total,
    pct_urls as pct
from `httparchive.blink_features.usage`
where feature = 'ServiceWorkerControlledPage'
order by date desc, client
