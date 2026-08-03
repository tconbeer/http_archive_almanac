# standardSQL
# 06_43: Top color font formats
select
    client,
    format,
    count(0) as freq,
    count(distinct page) as pages,
    total,
    round(count(0) * 100 / total, 2) as pct,
    round(count(distinct page) * 100 / total, 2) as pct_pages
from `httparchive.almanac.requests`
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (client),
    # Color fonts have any of sbix, cbdt, svg or colr tables.
    unnest(
        regexp_extract_all(
            json_extract(payload, '$._font_details.table_sizes'),
            '(?i)(sbix|cbdt|svg|colr)'
        )
    ) as format
where date = '2019-07-01' and type = 'font'
group by client, total, format
order by freq / total desc
