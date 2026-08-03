# standardSQL
# 21_11b: Distribution of Lighthouse scores for the 'Preload key requests' audit
select
    json_extract_scalar(report, '$.audits.uses-rel-preload.score') as score,
    count(0) as freq,
    sum(count(0)) over () as total,
    count(0) / sum(count(0)) over () as pct
from `httparchive.lighthouse.2020_08_01_mobile`
group by score
order by score
