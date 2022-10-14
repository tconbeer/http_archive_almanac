# standardSQL
# 15_04: Compression by Content type
select
    _table_suffix as client,
    mimetype,
    count(0) as num_requests,
    sum(if(resp_content_encoding = 'gzip', 1, 0)) as gzip,
    sum(if(resp_content_encoding = 'br', 1, 0)) as brotli,
    sum(if(resp_content_encoding = 'deflate', 1, 0)) as deflate,
    sum(
        if(resp_content_encoding in ('gzip', 'deflate', 'br'), 0, 1)
    ) as no_text_compression,
    round(
        sum(if(resp_content_encoding in ('gzip', 'deflate', 'br'), 1, 0)) / count(0), 2
    ) as pct_compressed,
    round(
        sum(if(resp_content_encoding = 'br', 1, 0)) / count(0), 2
    ) as pct_compressed_brotli
from `httparchive.summary_requests.2019_07_01_*`
group by client, mimetype
having num_requests > 1000
order by num_requests desc
