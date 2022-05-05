# standardSQL
# flexbox and grid adoption
select
    substr(yyyymmdd, 0, 4) as year,
    client,
    if(feature = 'CSSFlexibleBox', 'flexbox', 'grid') as layout,
    count(distinct url) as freq,
    total,
    count(distinct url) / total as pct
from `httparchive.blink_features.features`
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by client
    )
    using
    (client)
where
    yyyymmdd in ('20200801', '20190701') and
    feature in ('CSSFlexibleBox', 'CSSGridLayout')
group by year, client, layout, total
