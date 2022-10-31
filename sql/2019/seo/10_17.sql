# standardSQL
# 10_17: HTTP(S) adoption
select
    _table_suffix as client,
    countif(starts_with(url, 'https')) as https,
    countif(starts_with(url, 'http:')) as http,
    count(0) as total,
    round(countif(starts_with(url, 'https')) * 100 / count(0), 2) as pct_https,
    round(countif(starts_with(url, 'http:')) * 100 / count(0), 2) as pct_http
from `httparchive.summary_pages.2019_07_01_*`
group by client
