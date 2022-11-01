# standardSQL
# Total page weight distribution by CMS
select
    percentile,
    client,
    cms,
    count(0) as pages,
    approx_quantiles(total_kb, 1000)[offset(percentile * 10)] as total_kb
from
    (
        select distinct _table_suffix as client, url, app as cms
        from `httparchive.technologies.2021_07_01_*`
        where category = 'CMS'
    )
join
    (
        select _table_suffix as client, url, bytestotal / 1024 as total_kb
        from `httparchive.summary_pages.2021_07_01_*`
    ) using (client, url),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client, cms
having pages > 1000
order by percentile, pages desc
