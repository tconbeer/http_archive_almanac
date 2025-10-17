# standardSQL
# Lighthouse category scores per CMS
select
    app as cms,
    count(distinct url) as freq,
    # See
    # https://github.com/HTTPArchive/almanac.httparchive.org/pull/1087#issuecomment-684983795
    # APPROX_QUANTILES(CAST(JSON_EXTRACT_SCALAR(report,
    # '$.categories.performance.score') AS NUMERIC), 1000)[OFFSET(500)] AS
    # median_performance,
    approx_quantiles(
        cast(
            json_extract_scalar(report, '$.categories.accessibility.score') as numeric
        ),
        1000
    )[offset(500)] as median_accessibility,
    approx_quantiles(
        cast(json_extract_scalar(report, '$.categories.pwa.score') as numeric), 1000
    )[offset(500)] as median_pwa,
    approx_quantiles(
        cast(json_extract_scalar(report, '$.categories.seo.score') as numeric), 1000
    )[offset(500)] as median_seo,
    approx_quantiles(
        cast(
            json_extract_scalar(report, '$.categories.best-practices.score') as numeric
        ),
        1000
    )[offset(500)] as median_best_practices
from `httparchive.lighthouse.2020_08_01_mobile`
join `httparchive.technologies.2020_08_01_mobile` using (url)
where category = 'CMS'
group by cms
order by freq desc
