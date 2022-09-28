# standardSQL
# font-size
# score is not binary
select
    count(url) as total,
    countif(
        cast(json_extract_scalar(report, '$.audits.font-size.score') as numeric) = 1
    ) as score_sum,
    avg(
        cast(json_extract_scalar(report, '$.audits.font-size.score') as numeric)
    ) as score_average,
    round(
        countif(
            cast(json_extract_scalar(report, '$.audits.font-size.score') as numeric) = 1
        )
        * 100
        / count(url),
        2
    ) as score_percentage
from `httparchive.lighthouse.2019_07_01_mobile`
