# standardSQL
# Adoption of image formats in SSGs
with
    totals as (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2021_07_01_*`
        group by _table_suffix
    ),

    ssg as (
        select distinct _table_suffix as client, url, app as ssg_app
        from `httparchive.technologies.2021_07_01_*`
        where
            lower(
                category
            ) = 'static site generator' or app = 'Next.js' or app = 'Nuxt.js'
    ),

    total_ssg as (
        select _table_suffix as client, count(0) as ssg_total
        from `httparchive.technologies.2021_07_01_*`
        where
            lower(
                category
            ) = 'static site generator' or app = 'Next.js' or app = 'Nuxt.js'
        group by _table_suffix
    ),

    total_ssg_app as (
        select _table_suffix as client, app as ssg_app, count(0) as ssg_app_total
        from `httparchive.technologies.2021_07_01_*`
        where
            lower(
                category
            ) = 'static site generator' or app = 'Next.js' or app = 'Nuxt.js'
        group by _table_suffix, app
    ),

    js as (
        select distinct _table_suffix as client, url, app as js_app
        from `httparchive.technologies.2021_07_01_*`
        where category in ('JavaScript frameworks', 'JavaScript libraries')
    )

select
    client,
    ssg_app,
    js_app,
    count(distinct url) as num_urls,
    ssg_app_total,
    count(distinct url) / ssg_app_total as pct_urls_app,
    ssg_total,
    count(distinct url) / ssg_total as pct_urls_ssg,
    total,
    count(distinct url) / total as pct_urls_total
from ssg
join js using(client, url)
join totals using(client)
join total_ssg_app using(client, ssg_app)
join total_ssg using(client)
group by client, ssg_app, ssg_app_total, ssg_total, js_app, total
order by pct_urls_total desc, client, ssg_app, js_app
