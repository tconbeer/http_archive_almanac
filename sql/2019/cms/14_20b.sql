# standardSQL
# 14_20b: Lighthouse A11y scores by CMS
select
    app,
    approx_quantiles(
        cast(
            json_extract_scalar(report, '$.categories.accessibility.score') as numeric
        ),
        1000
    )[offset(501)] as median_a11y_score,
    count(0) as pages
from `httparchive.lighthouse.2019_07_01_mobile`
left join `httparchive.technologies.2019_07_01_mobile` using(url)
where category = 'CMS'
group by app
order by pages desc
