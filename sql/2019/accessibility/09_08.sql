# standardSQL
# 09_08: % of mobile pages with a valid html lang attribute
select
    countif(valid_lang) as valid_lang,
    countif(has_lang) as has_lang,
    count(0) as total,
    round(countif(has_lang) * 100 / count(0), 2) as pct_has_of_total,
    round(countif(valid_lang) * 100 / count(0), 2) as pct_valid_of_total,
    round(countif(valid_lang) * 100 / countif(has_lang), 2) as pct_valid_of_has
from
    (
        select
            json_extract_scalar(report, "$.audits['html-has-lang'].score")
            = '1' as has_lang,
            json_extract_scalar(report, "$.audits['html-valid-lang'].score")
            = '1' as valid_lang
        from `httparchive.lighthouse.2019_07_01_mobile`
    )
