# standardSQL
# 17_22: Percentage of responses with nopush directive
select
    _table_suffix as client,
    _cdn_provider as cdn,
    countif(lower(respotherheaders) like '%nopush%') as freq,
    count(0) as total,
    round(countif(lower(respotherheaders) like '%nopush%') * 100 / count(0), 2) as pct
from `httparchive.summary_requests.2019_07_01_*`
group by client, cdn
order by total desc
