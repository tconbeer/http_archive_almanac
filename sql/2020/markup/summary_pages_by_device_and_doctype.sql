# standardSQL
# Doctype M101
create temp function as_percent(freq float64, total float64)
returns float64
as (round(safe_divide(freq, total), 4))
;

select
    _table_suffix as client,
    # remove extra spaces and make lower case
    lower(regexp_replace(trim(doctype), r' +', ' ')) as doctype,
    count(0) as freq,
    as_percent(count(0), sum(count(0)) over (partition by _table_suffix)) as pct_m101
from `httparchive.summary_pages.2020_08_01_*`
group by client, doctype
order by freq desc, client
limit 100
