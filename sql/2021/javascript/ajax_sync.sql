# standardSQL
# usage of synchronous XMLHttpRequest using blink features from usage counters
select client, pct_urls
from `httparchive.blink_features.usage`
where yyyymmdd = '20210701' and feature = 'XMLHttpRequestSynchronous'
group by pct_urls, client
order by pct_urls, client
