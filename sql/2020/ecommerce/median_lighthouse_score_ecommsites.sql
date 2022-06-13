# standardSQL
# 13_20: Lighthouse category scores per eCommerce plaforms. Web Almanac run LightHouse
# only in mobile mode and hence references to mobile tables
# See
# https://github.com/HTTPArchive/almanac.httparchive.org/pull/1087#issuecomment-684983795. Due to this, using Sep-2020 in this query
select
    app as ecommvendor,
    count(distinct url) as freq,
    approx_quantiles(
        cast(json_extract_scalar(report, '$.categories.performance.score') as numeric),
        1000
    ) [offset (500)] as median_performance,
    approx_quantiles(
        cast(
            json_extract_scalar(report, '$.categories.accessibility.score') as numeric
        ),
        1000
    ) [offset (500)] as median_accessibility,
    approx_quantiles(
        cast(json_extract_scalar(report, '$.categories.pwa.score') as numeric), 1000
    ) [offset (500)] as median_pwa,
    approx_quantiles(
        cast(json_extract_scalar(report, '$.categories.seo.score') as numeric), 1000
    ) [offset (500)] as median_seo,
    approx_quantiles(
        cast(
            json_extract_scalar(report, '$.categories.best-practices.score') as numeric
        ),
        1000
    ) [offset (500)] as median_best_practices
from `httparchive.lighthouse.2020_09_01_mobile`
join `httparchive.technologies.2020_09_01_mobile` using(url)
where
    category = 'Ecommerce' and (
        app != 'Cart Functionality' and app != 'Google Analytics Enhanced eCommerce'
    )
group by ecommvendor
order by freq desc
