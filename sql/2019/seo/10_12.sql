# standardSQL
# 10_12: robots.txt
select
    json_extract_scalar(report, '$.audits.robots-txt.score') as score,
    count(0) as freq,
    sum(count(0)) over () as total,
    round(count(0) * 100 / sum(count(0)) over (), 2) as pct
from `httparchive.lighthouse.2019_07_01_mobile`
group by score
