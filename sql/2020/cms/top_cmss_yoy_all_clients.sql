# standardSQL
# Top CMS platforms, compared to 2019.
# Note that this query combines desktop and mobile datasets.
select
    2020 as year,
    app as cms,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from `httparchive.technologies.2020_08_01_*`
cross join
    (select count(distinct url) as total from `httparchive.summary_pages.2020_08_01_*`)
where category = 'CMS'
group by total, cms
union all
select
    2019 as year,
    app as cms,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from `httparchive.technologies.2019_07_01_*`
cross join
    (select count(distinct url) as total from `httparchive.summary_pages.2019_07_01_*`)
where category = 'CMS'
group by total, cms
order by pct desc, year desc
