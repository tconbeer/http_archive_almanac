# standardSQL
# Histogram of unused JS bytes per page
select
    if(
        unused_js_kbytes <= 1000, ceil(unused_js_kbytes / 20) * 20, 1000
    ) as unused_js_kbytes,
    count(0) / sum(count(0)) over (partition by 0) as pct,
    count(0) as pages,
    sum(count(0)) over (partition by 0) as total,
    -- only interested in last max one as a 'surprising metric'
    max(unused_js_kbytes) as max_unused_js_kb
from
    (
        select
            url as page,
            cast(
                json_extract(
                    report, '$.audits.unused-javascript.details.overallSavingsBytes'
                ) as int64
            )
            / 1024 as unused_js_kbytes
        from `httparchive.lighthouse.2021_07_01_mobile`
    )
group by unused_js_kbytes
order by unused_js_kbytes
