# standardSQL
# SSG adoptions and top SSGs YoY
select
    _table_suffix as client,
    2021 as year,
    app as ssg,
    count(0) as freq,
    total,
    count(0) / total as pct
from `httparchive.technologies.2021_07_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.summary_pages.2021_07_01_*`
        group by _table_suffix
    ) using (_table_suffix)
where lower(category) = 'static site generator' or app = 'Next.js' or app = 'Nuxt.js'
group by client, total, ssg
union all
select
    _table_suffix as client,
    2020 as year,
    app as ssg,
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
where lower(category) = 'static site generator' or app = 'Next.js' or app = 'Nuxt.js'
group by client, total, ssg
order by year desc, pct desc
