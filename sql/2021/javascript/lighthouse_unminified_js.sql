# standardSQL
# Pages with unminified JS
select
    score,
    count(0) as pages,
    sum(count(0)) over () as total,
    count(0) / sum(count(0)) over () as pct
from
    (
        select
            json_extract_scalar(
                report, "$.audits['unminified-javascript'].score"
            ) as score
        from `httparchive.lighthouse.2021_07_01_mobile`
    )
where score is not null
group by score
order by score
