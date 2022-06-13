# standardSQL
# Histogram of unused CSS bytes per page
select
    if(
        unused_css_kbytes <= 500, ceil(unused_css_kbytes / 10) * 10, 500
    ) as unused_css_kbytes,
    count(0) / sum(count(0)) over (partition by 0) as pct,
    count(0) as pages,
    sum(count(0)) over (partition by 0) as total,
    -- only interested in last max one as a 'surprising metric'
    max(unused_css_kbytes) as max_unused_css_kb
from
    (
        select
            url as page,
            cast(
                json_extract(
                    report, '$.audits.unused-css-rules.details.overallSavingsBytes'
                ) as int64
            ) / 1024 as unused_css_kbytes
        from `httparchive.lighthouse.2021_07_01_mobile`
    )
group by unused_css_kbytes
order by unused_css_kbytes
