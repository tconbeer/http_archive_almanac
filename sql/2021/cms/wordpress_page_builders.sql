# standardSQL
# Top WordPress page builder combinations
select
    client,
    page_builders,
    count(0) as pages,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select distinct _table_suffix as client, url
        from `httparchive.technologies.2021_07_01_*`
        where app = 'WordPress'
    )
join
    (
        select
            _table_suffix as client,
            url,
            array_to_string(array_agg(app order by app), ', ') as page_builders
        from `httparchive.technologies.2021_07_01_*`
        where category = 'Page builders'
        group by client, url
    ) using (client, url)
group by client, page_builders
order by pct desc
