# standardSQL
# 08_28: Groupings of "feature-policy" parsed values buckets
select
    _table_suffix as client,
    value,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by _table_suffix), 2) as pct
from
    `httparchive.summary_requests.2019_07_01_*`,
    unnest(
        regexp_extract_all(lower(respotherheaders), 'feature-policy = ([^,]+)')
    ) as value
where firsthtml
group by client, value
order by freq / total desc
