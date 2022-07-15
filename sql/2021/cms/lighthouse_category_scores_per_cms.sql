# standardSQL
# Lighthouse category scores per CMS
select
    cms,
    count(distinct url) as freq,
    approx_quantiles(
        cast(json_value(categories, '$.performance.score') as numeric),
        1000
    ) [offset (500)
    ] as median_performance,
    approx_quantiles(
        cast(json_value(categories, '$.accessibility.score') as numeric),
        1000
    ) [offset (500)
    ] as median_accessibility,
    approx_quantiles(
        cast(json_value(categories, '$.pwa.score') as numeric), 1000) [offset (500)
    ] as median_pwa,
    approx_quantiles(
        cast(json_value(categories, '$.seo.score') as numeric), 1000) [offset (500)
    ] as median_seo,
    approx_quantiles(
        cast(json_value(categories, '$."best-practices".score') as numeric),
        1000
    ) [offset (500)
    ] as median_best_practices
from
    (
        select url, json_extract(report, '$.categories') as categories
        from `httparchive.lighthouse.2021_07_01_mobile`
    )
join
    (
        select distinct app as cms, url
        from `httparchive.technologies.2021_07_01_mobile`
        where category = 'CMS'
    )
    using
    (url)
group by cms
order by freq desc
