# standardSQL
select _table_suffix as client, app, count(0) as freq, total, count(0) / total as pct
from `httparchive.technologies.2021_07_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.summary_pages.2021_07_01_*`
        group by _table_suffix
    )
    using
    (_table_suffix)
where category = 'Security'
group by client, total, app
order by pct desc
