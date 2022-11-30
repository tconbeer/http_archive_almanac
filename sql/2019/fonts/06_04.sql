# standardSQL
# 06_04: counts font-display value usage
select
    score,
    count(0) as freq,
    sum(count(0)) over () as total,
    round(count(0) * 100 / sum(count(0)) over (), 2) as pct
from
    (
        select json_extract(report, '$.audits.font-display.score') as score
        from `httparchive.lighthouse.2019_07_01_*`
    )
where score is not null
group by score
order by freq / total desc
