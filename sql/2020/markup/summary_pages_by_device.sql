# standardSQL
# summary_pages data grouped by device
# live is very cheap
create temp function as_percent(freq float64, total float64) returns float64 as (
    round(safe_divide(freq, total), 4)
)
;

select
    _table_suffix as client,
    countif(trim(doctype) != '') as freq_doctype,
    count(0) as total,
    as_percent(
        countif(trim(doctype) != ''), sum(count(0)) over (partition by _table_suffix)
    ) as pct_doctype_m102,
    min(byteshtml) as min_bytes_html_m109,
    max(byteshtml) as max_bytes_html_m108,
    round(avg(byteshtml), 0) as avg_bytes_html_m110,
    countif(byteshtml = 0) as freq_zero_bytes_html,
    as_percent(
        countif(byteshtml = 0), sum(count(0)) over (partition by _table_suffix)
    ) as pct_zero_bytes_html
from `httparchive.summary_pages.2020_08_01_*`
group by client
order by client
