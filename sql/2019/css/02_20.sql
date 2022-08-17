# standardSQL
# 02_20: Top 100 stylesheet names
select
    client,
    filename,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from
    (
        select
            _table_suffix as client,
            array_reverse(split(url, '/'))[offset(0)] as filename
        from `httparchive.summary_requests.2019_07_01_*`
        where type = 'css'
    )
group by client, filename
order by freq / total desc
limit 100
