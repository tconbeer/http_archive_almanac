# standardSQL
# 16_15: Use of AppCache
select
    count(0) as total_sites,
    countif(appcache_score is not null) as total_applicable,
    countif(cast(appcache_score as numeric) = 0) as total_using_appcache,
    round(
        countif(cast(appcache_score as numeric) = 0)
        * 100
        / countif(appcache_score is not null),
        2
    ) as perc_in_applicable,
    round(
        countif(cast(appcache_score as numeric) = 0) * 100 / count(0), 2
    ) as perc_in_all_sites
from
    (
        select
            json_extract_scalar(
                report, '$.audits.appcache-manifest.score'
            ) as appcache_score
        from `httparchive.lighthouse.2019_07_01_mobile`
    )
