# standardSQL
# Top CMS platforms, compared to 2019
select
    _table_suffix as client,
    2020 as year,
    app as cms,
    count(0) as freq,
    total,
    count(0) / total as pct
from `httparchive.technologies.2020_08_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by _table_suffix
    ) using (_table_suffix)
where category = 'CMS'
group by client, total, cms
union all
select
    _table_suffix as client,
    2019 as year,
    app as cms,
    count(0) as freq,
    total,
    count(0) / total as pct
from `httparchive.technologies.2019_07_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (_table_suffix)
where category = 'CMS'
group by client, total, cms
order by year desc, pct desc
