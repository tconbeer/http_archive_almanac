# standardSQL
# Distribution of LH6 performance score.
select
    json_extract_scalar(report, '$.categories.performance.score') as score,
    count(0) as freq,
    sum(count(0)) over () as total,
    count(0) / sum(count(0)) over () as pct
from `httparchive.lighthouse.2020_09_01_mobile`
group by score
order by score
