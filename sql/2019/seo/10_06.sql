# standardSQL
# 10_06: Indexability - looking at meta tags like <meta> noindex, <link> canonicals.
select
    countif(is_crawlable) as crawlable,
    countif(is_canonical) as canonical,
    count(0) as total,
    round(countif(is_crawlable) * 100 / count(0), 2) as pct_crawlable,
    round(countif(is_canonical) * 100 / count(0), 2) as pct_canonical
from
    (
        select
            json_extract_scalar(
                report, '$.audits.is-crawlable.score'
            ) = '1' as is_crawlable,
            json_extract_scalar(
                report, '$.audits.canonical.score'
            ) = '1' as is_canonical
        from `httparchive.lighthouse.2019_07_01_mobile`
    )
