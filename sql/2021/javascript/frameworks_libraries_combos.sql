# standardSQL
# Top JS frameworks and libraries combinations
select *
from
    (
        select
            client,
            apps,
            count(distinct page) as pages,
            total,
            count(distinct page) / total as pct
        from
            (
                select
                    _table_suffix as client,
                    url as page,
                    total,
                    array_to_string(array_agg(app order by app), ', ') as apps
                from `httparchive.technologies.2021_07_01_*`
                join
                    (
                        select _table_suffix, count(0) as total
                        from `httparchive.summary_pages.2021_07_01_*`
                        group by _table_suffix
                    )
                    using
                    (_table_suffix)
                where category in ('JavaScript frameworks', 'JavaScript libraries')
                group by client, url, total
            )
        group by client, apps, total
    )
where pages >= 10000
order by pct desc
