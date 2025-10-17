# standardSQL
# 21_13: Distribution of Lighthouse scores for the 'Defer offscreen images' audit
select
    json_extract_scalar(report, '$.audits.offscreen-images.score') as score,
    count(0) as freq,
    sum(count(0)) over () as total,
    count(0) / sum(count(0)) over () as pct
from `httparchive.lighthouse.2020_08_01_mobile`
group by score
order by score
