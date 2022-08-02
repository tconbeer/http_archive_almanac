# standardSQL
# 10_14: Descriptive link text usage
select
    countif(link_text) as freq,
    count(0) as total,
    round(countif(link_text) * 100 / count(0), 2) as pct
from
    (
        select
            json_extract_scalar(report, '$.audits.link-text.score') = '1' as link_text
        from `httparchive.lighthouse.2019_07_01_mobile`
    )
