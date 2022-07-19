# standardSQL
# 14_20: Lighthouse A11y scores
select
    json_extract_scalar(report, '$.categories.accessibility.score') as a11y_score,
    count(0) as freq,
    sum(count(0)) over () as total,
    round(count(0) * 100 / sum(count(0)) over (), 2) as pct
from `httparchive.lighthouse.2019_07_01_mobile`
left join `httparchive.technologies.2019_07_01_mobile` using(url)
where category = 'CMS'
group by a11y_score
having a11y_score is not null
order by freq / total desc
