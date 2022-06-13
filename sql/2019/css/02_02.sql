# standardSQL
# 02_02: % of sites that use @import and @supports.
select
    client,
    sum(if(ends_with(feature, 'Import'), freq, 0)) as freq_import,
    sum(if(ends_with(feature, 'Supports'), freq, 0)) as freq_supports,
    total,
    round(
        sum(if(ends_with(feature, 'Import'), freq, 0)) * 100 / total, 2
    ) as pct_import,
    round(
        sum(if(ends_with(feature, 'Supports'), freq, 0)) * 100 / total, 2
    ) as pct_supports
from
    (
        select client, feature, count(distinct url) as freq
        from `httparchive.blink_features.features`
        where
            yyyymmdd = '20190701' and feature in (
                'CSSAtRuleImport', 'CSSAtRuleSupports'
            )
        group by client, feature
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by client
    )
    using
    (client)
group by client, total
