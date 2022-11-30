# standardSQL
select
    _table_suffix as client,
    app,
    count(0) as freq,
    total,
    round(count(0) * 100 / total, 2) as pct
from `httparchive.technologies.2020_08_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by _table_suffix
    ) using (_table_suffix)
where category = 'Security'
group by client, total, app
order by freq / total desc
