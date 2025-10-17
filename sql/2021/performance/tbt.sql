# standardSQL
# TBT data by threshold
with
    tbt_stats as (
        select
            url,
            cast(
                json_extract_scalar(
                    report, '$.audits.total-blocking-time.numericValue'
                ) as float64
            ) as tbtvalue,
            cast(
                json_extract_scalar(
                    report, '$.audits.total-blocking-time.score'
                ) as float64
            ) as tbtscore
        from `httparchive.lighthouse.2021_07_01_mobile`
    )

select
    case
        when tbtscore < 0.5 then 'POOR' when tbtscore < 0.9 then 'NI' else 'GOOD'
    end as tbt,
    count(0) as pages,
    sum(count(0)) over () as total,
    count(0) / sum(count(0)) over () as pct
from tbt_stats
group by tbt
order by tbt
