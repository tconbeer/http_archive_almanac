# standardSQL
# 14_01b: % CMS (any)
select
    _table_suffix as client,
    count(0) as freq,
    total,
    round(count(0) * 100 / total, 2) as pct
from `httparchive.technologies.2019_07_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    )
    using(_table_suffix)
where category = 'CMS'
group by client, total
order by freq / total desc
