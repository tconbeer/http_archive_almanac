# standardSQL
# 13_13: Lighthouse PWA scores
select
    json_extract_scalar(report, '$.categories.pwa.score') as pwa_score,
    count(0) as freq,
    sum(count(0)) over () as total,
    round(count(0) * 100 / sum(count(0)) over (), 2) as pct
from `httparchive.lighthouse.2019_07_01_mobile`
left join `httparchive.technologies.2019_07_01_mobile` using (url)
where category = 'Ecommerce'
group by pwa_score
order by freq / total desc
