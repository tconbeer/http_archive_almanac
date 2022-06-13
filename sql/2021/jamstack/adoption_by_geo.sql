# standardSQL
# All SSG popularity per geo
with
    geo_summary as (
        select
            `chrome-ux-report`.experimental.get_country(country_code) as geo,
            if(device = 'desktop', 'desktop', 'mobile') as client,
            origin,
            count(distinct origin) over (
                partition by country_code, if(device = 'desktop', 'desktop', 'mobile')
            ) as total
        from `chrome-ux-report.materialized.country_summary`
        # We're intentionally using May 2021 CrUX data here.
        # That's because there's a two month lag between CrUX and HA datasets.
        # Since we're only JOINing with the CrUX dataset to see which URLs
        # belong to different countries (as opposed to CWV field data)
        # it's not necessary to look at the 202107 dataset.
        where yyyymm = 202105
    )

select *
from
    (
        select
            app,
            client,
            geo,
            count(0) as pages,
            count(distinct url) as origins,
            any_value(total) as total,
            count(0) / any_value(total) as pct
        from
            (
                select distinct geo, client, total, concat(origin, '/') as url
                from geo_summary
            )
        join
            (
                select distinct _table_suffix as client, app, url
                from `httparchive.technologies.2021_07_01_*`
                where
                    lower(
                        category
                    ) = 'static site generator' or app = 'Next.js' or app = 'Nuxt.js'
            ) using(client, url)
        group by app, client, geo
        order by origins desc
    )
