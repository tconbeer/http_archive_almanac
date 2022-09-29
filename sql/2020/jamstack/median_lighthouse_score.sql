# standardSQL
# Lighthouse category scores per SSG
select
    _table_suffix as client,
    app as ssg,
    count(distinct url) as freq,
    approx_quantiles(
        cast(json_extract_scalar(report, '$.categories.performance.score') as numeric),
        1000
    )[offset(500)] as median_performance,
    approx_quantiles(
        cast(
            json_extract_scalar(report, '$.categories.accessibility.score') as numeric
        ),
        1000
    )[offset(500)] as median_accessibility,
    approx_quantiles(
        cast(json_extract_scalar(report, '$.categories.pwa.score') as numeric), 1000
    )[offset(500)] as median_pwa
from `httparchive.lighthouse.2020_09_01_*`
join `httparchive.technologies.2020_09_01_*` using (_table_suffix, url)
where
    lower(category) = 'static site generator'
    or app = 'Next.js'
    or app = 'Nuxt.js'
    or app = 'Docusaurus'
group by ssg, client
order by freq desc
