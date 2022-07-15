# standardSQL
# 09_20: % of mobile pages with valid aria attribute values, scored by Lighthouse
select
    is_valid,
    count(0) as pages,
    sum(count(0)) over () as total,
    round(count(0) * 100 / sum(count(0)) over (), 2) as pct
from
    (
        select
            json_extract_scalar(report, "$.audits['aria-valid-attr-value'].score")
            = '1' as is_valid
        from `httparchive.lighthouse.2019_07_01_mobile`
    )
# Ignore pages with no aria-* attributes
where is_valid is not null
group by is_valid
order by pages desc
