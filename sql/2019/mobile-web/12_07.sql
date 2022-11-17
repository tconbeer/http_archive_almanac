# standardSQL
# 12_07: % of pages using ScreenOrientation.lock()
select num_urls as freq, total_urls as total, round(pct_urls * 100, 2) as pct
from `httparchive.blink_features.usage`
where client = 'mobile' and yyyymmdd = '20190701' and feature = 'ScreenOrientationLock'
