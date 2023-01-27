# standardSQL
# 04_13: Lighthouse img alt
select
    countif(pass) as freq,
    count(0) as total,
    round(countif(pass) * 100 / count(0), 2) as pct
from
    (
        select json_extract_scalar(report, '$.audits.image-alt.score') = '1' as pass
        from `httparchive.lighthouse.2019_07_01_mobile`
    )
