# standardSQL
# Max TBT
select
    max(
        cast(
            json_extract_scalar(
                report, '$.audits.total-blocking-time.numericValue'
            ) as float64
        )
    ) as maxtbt
from `httparchive.lighthouse.2021_07_01_mobile`
