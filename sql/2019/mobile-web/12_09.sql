# standardSQL
# notification-on-start
select
    count(url) as total,
    countif(
        cast(
            json_extract_scalar(
                report, '$.audits.notification-on-start.score'
            ) as numeric
        ) = 1
    ) as score_sum,
    round(
        countif(
            cast(
                json_extract_scalar(
                    report, '$.audits.notification-on-start.score'
                ) as numeric
            ) = 1
        ) * 100 / count(url),
        2
    ) as score_percentage
from `httparchive.lighthouse.2019_07_01_mobile`
