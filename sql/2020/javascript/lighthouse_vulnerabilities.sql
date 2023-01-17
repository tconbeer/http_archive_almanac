# standardSQL
# Pages with vulnerable libraries
select
    score,
    count(0) as pages,
    sum(count(0)) over () as total,
    count(0) / sum(count(0)) over () as pct
from
    (
        select
            json_extract_scalar(
                report, "$.audits['no-vulnerable-libraries'].score"
            ) as score
        from `httparchive.lighthouse.2020_08_01_mobile`
    )
where score is not null
group by score
order by score
