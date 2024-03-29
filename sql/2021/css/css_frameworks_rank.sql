# standardSQL
# Most popular CSS frameworks by rank
select
    client,
    framework,
    rank,
    count(distinct page) as pages,
    count(distinct page) / rank as pct
from
    (
        select _table_suffix as client, url as page, rank as _rank
        from `httparchive.summary_pages.2021_07_01_*`
    )
left join
    (
        select distinct _table_suffix as client, app as framework, url as page
        from `httparchive.technologies.2021_07_01_*`
        where category = 'UI frameworks'
    ) using (client, page),
    unnest([1e3, 1e4, 1e5, 1e6, 1e7]) as rank
where _rank <= rank
group by client, framework, rank
order by rank, pct desc
