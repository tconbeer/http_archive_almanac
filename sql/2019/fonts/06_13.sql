# standardSQL
# 06_13: Font Loading API usage
select client, num_urls as freq, total_urls as total, round(pct_urls * 100, 2) as pct
from `httparchive.blink_features.usage`
where feature = 'FontFaceConstructor' and yyyymmdd = '20190701'
