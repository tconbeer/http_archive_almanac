# standardSQL
# flexbox and grid adoption
with
    totals as (
        select
            cast('2021-07-01' as date) as yyyymmdd,
            _table_suffix as client,
            count(0) as total
        from `httparchive.summary_pages.2021_07_01_*`
        group by client
        union all
        select
            cast('2020-08-01' as date) as yyyymmdd,
            _table_suffix as client,
            count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by client
        union all
        select
            cast('2019-07-01' as date) as yyyymmdd,
            _table_suffix as client,
            count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by client
    )

select
    substr(cast(yyyymmdd as string), 0, 4) as year,
    client,
    if(feature = 'CSSFlexibleBox', 'flexbox', 'grid') as layout,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from `httparchive.blink_features.features`
join totals using(yyyymmdd, client)
where
    yyyymmdd in ('2021-07-01', '2020-08-01', '2019-07-01')
    and feature in ('CSSFlexibleBox', 'CSSGridLayout')
group by year, client, layout, total
order by year desc, pct desc
