# standardSQL
# 06_18-19: % of pages that include a variable font
select
    client,
    count(distinct page) as freq,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from `httparchive.almanac.requests`
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    )
    using
    (client)
where
    date = '2019-07-01'
    and type = 'font'
    and json_extract_scalar(payload, '$._font_details.table_sizes.gvar') is not null
group by client, total
