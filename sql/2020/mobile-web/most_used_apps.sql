# standardSQL
# Most used apps
select
    total_sites,

    category,
    app,
    count(0) as sites_with_app,
    count(0) / total_sites as pct_sites_with_app
from `httparchive.technologies.2020_08_01_mobile`
cross join
    (select count(0) as total_sites from `httparchive.summary_pages.2020_08_01_mobile`)
group by total_sites, category, app
order by pct_sites_with_app desc
