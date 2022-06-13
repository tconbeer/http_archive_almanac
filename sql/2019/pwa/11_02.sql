# standardSQL
# 11_02: Check for 'Installable Manifest' missing noted in Lighthouse run
select
    countif(manifest) as freq,
    count(0) as total,
    round(countif(manifest) * 100 / count(0), 2) as pct
from
    (
        select
            json_extract_scalar(
                report, '$.audits.installable-manifest.score'
            ) = '1' as manifest
        from `httparchive.lighthouse.2019_07_01_mobile`
    )
