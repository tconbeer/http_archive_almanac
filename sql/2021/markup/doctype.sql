# standardSQL
# doctype
select
    _table_suffix as client,
    lower(regexp_replace(trim(doctype), r' +', ' ')) as doctype,  # remove extra spaces and make lower case
    count(0) as freq,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct
from `httparchive.summary_pages.2021_07_01_*`
group by client, doctype
order by pct desc, client, freq desc
limit 100
