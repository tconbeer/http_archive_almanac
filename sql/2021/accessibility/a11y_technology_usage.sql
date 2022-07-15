# standardSQL
# A11Y technology usage
select
    client,
    total_sites,
    sites_with_a11y_tech,
    sites_with_a11y_tech / total_sites as perc_sites_with_a11y_tech
from
    (
        select _table_suffix as client, count(distinct url) as sites_with_a11y_tech
        from `httparchive.technologies.2021_07_01_*`
        where category = 'Accessibility'
        group by client
    )
join
    (
        select _table_suffix as client, count(0) as total_sites
        from `httparchive.summary_pages.2021_07_01_*`
        group by client
    )
    using(client)
