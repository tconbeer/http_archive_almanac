# standardSQL
# CMS adoption per rank
select
    client,
    cms,
    rank,
    count(distinct url) as pages,
    any_value(total) as total,
    count(distinct url) / any_value(total) as pct
from
    (
        select distinct _table_suffix as client, app as cms, url
        from `httparchive.technologies.2021_07_01_*`
        where category = 'CMS'
    )
join
    (
        select _table_suffix as client, url, rank
        from `httparchive.summary_pages.2021_07_01_*`
    )
    using
    (client, url)
join
    (
        select _table_suffix as client, rank_magnitude as rank, count(0) as total
        from
            `httparchive.summary_pages.2021_07_01_*`,
            unnest([1 e3, 1 e4, 1 e5, 1 e6, 1 e7]) as rank_magnitude
        where rank <= rank_magnitude
        group by _table_suffix, rank_magnitude
    )
    using
    (client, rank),
    unnest([1 e3, 1 e4, 1 e5, 1 e6, 1 e7]) as rank_magnitude
where rank <= rank_magnitude
group by client, cms, rank
order by rank, pages desc
