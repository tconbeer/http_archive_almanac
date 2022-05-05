# standardSQL
# 08_40: Check for 'Vulnerable JS' noted in Lighthouse run
# 
# Lighthouse score = 0 - means site contains at min 1 vulnerable JS
select
    json_extract_scalar(report, '$.audits.no-vulnerable-libraries.score') as score,
    count(0) as freq,
    sum(count(0)) over () as total,
    round(count(0) * 100 / sum(count(0)) over (), 2) as pct
from `httparchive.lighthouse.2019_07_01_mobile`
group by score
order by freq desc
