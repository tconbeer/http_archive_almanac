# standardSQL
# summary_pages trends grouped by device
with
    summary_requests as (
        select '2019' as year, _table_suffix as client, *
        from `httparchive.summary_pages.2019_07_01_*`
        union all
        select '2020' as year, _table_suffix as client, *
        from `httparchive.summary_pages.2020_08_01_*`
        union all
        select '2021' as year, _table_suffix as client, *
        from `httparchive.summary_pages.2021_07_01_*`
    )

select
    year,
    client,
    countif(trim(doctype) != '') as freq_doctype,
    countif(trim(doctype) != '') / count(0) as pct_doctype,
    min(byteshtml) as min_bytes_html,
    max(byteshtml) as max_bytes_html,
    approx_quantiles(byteshtml, 1000)[offset(500)] as median_bytes_html,
    countif(byteshtml = 0) as freq_zero_bytes_html,
    countif(byteshtml = 0) / count(0) as pct_zero_bytes_html,
    count(0) as total
from summary_requests
group by year, client
order by year, client
