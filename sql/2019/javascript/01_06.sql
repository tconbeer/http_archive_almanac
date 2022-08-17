# standardSQL
# 01_06: Percent of scripts that are brotli encoded.
select
    _table_suffix as client,
    round(countif(resp_content_encoding = 'br') * 100 / count(0), 2) as pct_brotli
from `httparchive.summary_requests.2019_07_01_*`
where type = 'script'
group by client
