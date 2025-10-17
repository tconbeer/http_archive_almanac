# standardSQL
# 10_09b: image alt attribute usage
select
    countif(img_alt) as freq,
    count(0) as total,
    round(countif(img_alt) * 100 / count(0), 2) as pct
from
    (
        select json_extract_scalar(report, '$.audits.image-alt.score') = '1' as img_alt
        from `httparchive.lighthouse.2019_07_01_mobile`
    )
