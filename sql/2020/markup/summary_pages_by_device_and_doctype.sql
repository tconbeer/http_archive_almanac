# standardSQL
# Doctype M101
CREATE TEMP FUNCTION AS_PERCENT (freq FLOAT64, total FLOAT64) RETURNS FLOAT64 AS (
  ROUND(SAFE_DIVIDE(freq, total), 4)
);

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
