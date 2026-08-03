# standardSQL
# 17_10: Percentage of responses with vary header
select
    _table_suffix as client,
    _cdn_provider as cdn,
    countif(resp_vary != '') as freq,
    count(0) as total,
    round(countif(resp_vary != '') * 100 / count(0), 2) as pct
from `httparchive.summary_requests.2019_07_01_*`
group by client, cdn
order by total desc
