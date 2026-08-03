# standardSQL
# 08_27: Groupings of "referrer-policy" parsed values buckets
select
    _table_suffix as client,
    policy,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by _table_suffix), 2) as pct
from
    `httparchive.summary_requests.2019_07_01_*`,
    unnest(
        regexp_extract_all(lower(respotherheaders), 'referrer-policy = ([^,]+)')
    ) as policy
where firsthtml
group by client, policy
order by freq / total desc
