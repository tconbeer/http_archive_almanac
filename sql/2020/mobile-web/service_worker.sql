# standardSQL
# Sites registering a service worker
select
    count(0) as total,
    countif(
        cast(
            json_extract_scalar(report, '$.audits.service-worker.score') as numeric
        ) = 1
    ) as score_sum,
    countif(
        cast(
            json_extract_scalar(report, '$.audits.service-worker.score') as numeric
        ) = 1
    ) / count(0) as score_percentage
from `httparchive.lighthouse.2020_08_01_mobile`
