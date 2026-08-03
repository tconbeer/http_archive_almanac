select
    _table_suffix as client,
    cdn,
    count(0) as requests,
    avg(respsize) / 1024 as avg_resp_kbytes,
    approx_quantiles(respsize, 1000)[offset(500)] / 1024 as median_resp_kbytes
from
    `httparchive.summary_requests.2021_07_01_*`,
    unnest(split(_cdn_provider, ', ')) as cdn
group by client, cdn
order by requests desc
