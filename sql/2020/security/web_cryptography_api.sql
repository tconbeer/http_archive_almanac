# standardSQL
select client, feature, num_urls, total_urls, pct_urls
from `httparchive.blink_features.usage`
where (feature like 'Crypto%' or feature like 'Subtle%') and yyyymmdd = '20200801'
order by pct_urls desc
