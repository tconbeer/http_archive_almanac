# standardSQL
# 10_07a: <title> and <meta description> present
select
    countif(has_title) as doc_title,
    countif(has_meta_description) as meta_description,
    countif(has_title and has_meta_description) as both,
    count(0) as total,
    round(countif(has_title) * 100 / count(0), 2) as pct_title,
    round(countif(has_meta_description) * 100 / count(0), 2) as pct_desc,
    round(countif(has_title and has_meta_description) * 100 / count(0), 2) as pct_both
from
    (
        select
            json_extract_scalar(
                report, '$.audits.document-title.score'
            ) = '1' as has_title,
            json_extract_scalar(
                report, '$.audits.meta-description.score'
            ) = '1' as has_meta_description
        from `httparchive.lighthouse.2019_07_01_mobile`
    )
