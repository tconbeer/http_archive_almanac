# standardSQL
# LCP element node
# This is a simplified query - the lcp_element_data.sql one will probably be used
# instead. Leaving this here for reference for now.
select
    _table_suffix as client,
    json_extract_scalar(
        payload, '$._performance.lcp_elem_stats[0].nodeName'
    ) as lcp_node,
    count(distinct url) as pages,
    any_value(total) as total,
    count(distinct url) / any_value(total) as pct
from `httparchive.pages.2021_07_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.summary_pages.2021_07_01_*`
        group by _table_suffix
    ) using (_table_suffix)
group by client, lcp_node
having pages > 1000
order by pct desc
