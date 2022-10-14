select client, feature, num_urls as freq, total_urls as total, pct_urls as pct_pages
from `httparchive.blink_features.usage`
where yyyymmdd = '20200801'
order by pct_pages desc
