# standardSQL
# 14_19b: Lighthouse PWA scores by CMS
select
    app,
    approx_quantiles(
        cast(json_extract_scalar(report, '$.categories.pwa.score') as numeric),
        1000
    ) [offset (501)
    ] as median_pwa_score,
    count(0) as pages
from `httparchive.lighthouse.2019_07_01_mobile`
left join `httparchive.technologies.2019_07_01_mobile` using(url)
where category = 'CMS'
group by app
order by pages desc
