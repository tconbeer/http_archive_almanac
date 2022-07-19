# standardSQL
# Sum of JS request bytes per page by framework (2020)
select
    percentile,
    client,
    app as js_framework,
    count(distinct page) as pages,
    approx_quantiles(bytesjs / 1024, 1000)[offset(percentile * 10)] as js_kilobytes
from
    (
        select _table_suffix as client, url as page, bytesjs
        from `httparchive.summary_pages.2020_08_01_*`
    )
join
    (
        select distinct _table_suffix as client, url as page, app
        from `httparchive.technologies.2020_08_01_*`
        where category = 'JavaScript frameworks'
    )
    using
    (client, page),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client, js_framework
order by percentile, client, pages desc
