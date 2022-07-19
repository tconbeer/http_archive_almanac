# standardSQL
# 06_42: % of pages that include a color font
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
    # Color fonts have any of sbix, cbdt, svg or colr tables.
    and array_length(
        regexp_extract_all(
            json_extract(payload, '$._font_details.table_sizes'),
            '(?i)(sbix|cbdt|svg|colr)'
        )
    )
    > 0
group by client, total
