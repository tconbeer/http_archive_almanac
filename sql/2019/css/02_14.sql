# standardSQL
# 02_14: % of sites that use Grid layout.
select
    client,
    count(distinct url) as freq,
    round(count(distinct url) * 100 / total, 2) as pct
from `httparchive.blink_features.features`
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by client
    )
    using
    (client)
where yyyymmdd = '20190701' and feature = 'CSSGridLayout'
group by client, feature, total
