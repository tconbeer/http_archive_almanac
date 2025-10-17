# standardSQL
# Percent of websites using top Consent Management Platforms
with
    apps as (
        select
            _table_suffix as client,
            url,
            if(category = 'Cookie compliance', app, '') as cmp_app
        from `httparchive.technologies.2020_08_01_*`
        group by client, url, cmp_app
    ),

    base as (
        select
            client,
            url,
            cmp_app,
            count(distinct url) over (partition by client) as total_pages,
            count(distinct url) / count(distinct url) over () as pct_pages_with_cmp
        from apps
        group by client, url, cmp_app
    )

select
    client,
    cmp_app,
    any_value(total_pages) as total_pages,
    count(distinct url) / any_value(total_pages) as pct_pages_with_cmp
from base
where cmp_app != ''
group by client, cmp_app
