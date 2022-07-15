# standardSQL
# color_fonts
select
    client,
    format,
    count(distinct page) as pages_color,
    total_page,
    count(distinct page) / total_page as pct_color
from
    (
        select client, page, format, payload
        from `httparchive.almanac.requests`
        where date = '2021-07-01' and type = 'font'
    )
join
    (
        select _table_suffix as client, count(0) as total_page
        from `httparchive.summary_pages.2021_07_01_*`
        group by _table_suffix
    )
    using
    (client),
    # Color fonts have any of sbix, cbdt, svg or colr tables.
    unnest(
        regexp_extract_all(
            json_extract(payload, '$._font_details.table_sizes'),
            '(?i)(sbix|CBDT|SVG|COLR)'
        )
    ) as format
group by client, total_page, format
order by pages_color desc
