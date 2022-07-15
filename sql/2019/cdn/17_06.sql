# standardSQL
# 17_06: Percentage of responses with timing-allow-origin header
select
    _table_suffix as client,
    _cdn_provider as cdn,
    countif(lower(respotherheaders) like '%timing-allow-origin%') as freq,
    count(0) as total,
    round(
        countif(lower(respotherheaders) like '%timing-allow-origin%') * 100 / count(0),
        2
    ) as pct
from `httparchive.summary_requests.2019_07_01_*`
group by client, cdn
order by total desc
