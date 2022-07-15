# standardSQL
# % of mobile sites with a valid html lang attribute
select
    count(0) as total,
    countif(valid_lang) as valid_lang,
    countif(has_lang) as has_lang,
    countif(has_lang) / count(0) as pct_has_of_total,
    countif(valid_lang) / count(0) as pct_valid_of_total
from
    (
        select
            json_extract_scalar(report, "$.audits['html-has-lang'].score")
            = '1' as has_lang,
            json_extract_scalar(report, "$.audits['html-lang-valid'].score")
            = '1' as valid_lang
        from `httparchive.lighthouse.2020_08_01_mobile`
    )
