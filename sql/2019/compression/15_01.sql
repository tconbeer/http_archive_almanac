# standardSQL
# 15_01: What compression formats are being used (gzip, brotli, etc)
select
    _table_suffix as client,
    resp_content_encoding,
    count(0) as num_requests,
    round(count(0) * 100 / sum(count(0)) over (partition by _table_suffix), 2) as pct
from `httparchive.summary_requests.2019_07_01_*`
group by client, resp_content_encoding
order by num_requests desc
