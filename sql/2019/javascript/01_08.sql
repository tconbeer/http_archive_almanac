# standardSQL
# 01_08: Top JS libraries
select
    app,
    _table_suffix as client,
    count(distinct url) as freq,
    total,
    round(count(distinct url) * 100 / total, 2) as pct
from
    (
        select _table_suffix, count(distinct url) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    )
join `httparchive.technologies.2019_07_01_*` using(_table_suffix)
where category = 'JavaScript Libraries'
group by app, client, total
order by freq desc
