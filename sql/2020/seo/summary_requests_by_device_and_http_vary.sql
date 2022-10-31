# standardSQL
# if header contains vary by user-agent
create temp function as_percent(freq float64, total float64)
returns float64
as (round(safe_divide(freq, total), 4))
;

select
    _table_suffix as client,
    regexp_contains(lower(resp_vary), r'user-agent') as resp_vary_user_agent,
    count(0) as freq,
    as_percent(count(0), sum(count(0)) over (partition by _table_suffix)) as pct
from `httparchive.summary_requests.2020_08_01_*`
where firsthtml
group by client, resp_vary_user_agent
order by freq desc, client
