# standardSQL
# Most used technologies - mobile only
select
    total_pages,

    category,
    app,
    count(0) as pages_with_app,
    count(0) / total_pages as pct_pages_with_app
from `httparchive.technologies.2021_07_01_mobile`
cross join
    (select count(0) as total_pages from `httparchive.summary_pages.2021_07_01_mobile`)
group by total_pages, category, app
order by pct_pages_with_app desc
