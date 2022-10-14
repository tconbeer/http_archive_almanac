# standardSQL
# 17_25: Percentage of responses with Surrogate-Control headers
select
    _table_suffix as client,
    _cdn_provider as cdn,
    countif(lower(respotherheaders) like '%surrogate-control%') as freq,
    count(0) as total,
    round(
        countif(lower(respotherheaders) like '%surrogate-control%') * 100 / count(0), 2
    ) as pct
from `httparchive.summary_requests.2019_07_01_*`
group by client, cdn
order by total desc
