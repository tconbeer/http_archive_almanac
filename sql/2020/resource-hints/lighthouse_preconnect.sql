# standardSQL
# 21_11a: Distribution of Lighthouse scores for the 'Preconnect to required origins'
# audit
select
    json_extract_scalar(report, '$.audits.uses-rel-preconnect.score') as score,
    count(0) as freq,
    sum(count(0)) over () as total,
    count(0) / sum(count(0)) over () as pct
from `httparchive.lighthouse.2020_08_01_mobile`
group by score
order by score
