# standardSQL
# 01_05: Percent of scripts that are gzipped.
select
    _table_suffix as client,
    round(countif(resp_content_encoding = 'gzip') * 100 / count(0), 2) as pct_gzip
from `httparchive.summary_requests.2019_07_01_*`
where type = 'script'
group by client
