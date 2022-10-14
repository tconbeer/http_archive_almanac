# standardSQL
# Top JS frameworks and libraries
select
    _table_suffix as client,
    category,
    app,
    count(distinct url) as pages,
    total,
    count(distinct url) / total as pct
from `httparchive.technologies.2020_08_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by _table_suffix
    ) using (_table_suffix)
where category in ('JavaScript frameworks', 'JavaScript libraries')
group by client, category, app, total
order by pct desc
