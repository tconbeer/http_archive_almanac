# standardSQL
# 01_10: Top JS frameworks
select
    app,
    _table_suffix as client,
    count(0) as freq,
    total,
    round(count(0) * 100 / total, 2) as pct
from
    (
        select _table_suffix, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    )
join `httparchive.technologies.2019_07_01_*` using(_table_suffix)
where category = 'JavaScript Frameworks'
group by app, client, total
order by freq desc
