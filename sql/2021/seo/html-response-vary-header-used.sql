# standardSQL
# HTML response: vary header used
select
    _table_suffix as client,
    regexp_contains(lower(resp_vary), r'user-agent') as resp_vary_user_agent,
    count(0) as freq,
    safe_divide(count(0), sum(count(0)) over (partition by _table_suffix)) as pct
from `httparchive.summary_requests.2021_07_01_*`
where firsthtml
group by client, resp_vary_user_agent
order by freq desc, client
