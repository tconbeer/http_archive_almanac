# standardSQL
# HTML response: content language
select
    _table_suffix as client,
    lower(resp_content_language) as resp_content_language,
    count(0) as freq,
    safe_divide(count(0), sum(count(0)) over (partition by _table_suffix)) as pct
from `httparchive.summary_requests.2021_07_01_*`
where firsthtml
group by client, resp_content_language
qualify freq >= 100
order by freq desc, client
