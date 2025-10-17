# standardSQL
# 06_34: Web fonts loaded per page
select
    _table_suffix as client,
    reqfont as fonts,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by _table_suffix), 2) as pct
from `httparchive.summary_pages.2019_07_01_*`
group by client, fonts
order by freq / total desc
