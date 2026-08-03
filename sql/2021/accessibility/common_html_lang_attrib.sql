# standardSQL
# Most common html lang attributes
select
    _table_suffix as client,
    lower(
        json_extract_scalar(
            json_extract_scalar(payload, '$._almanac'), '$.html_node.lang'
        )
    ) as lang,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix) as total,
    count(0) / sum(count(0)) over (partition by _table_suffix) as pct_of_pages
from `httparchive.pages.2021_07_01_*`
group by _table_suffix, lang
having freq >= 100
order by pct_of_pages desc
