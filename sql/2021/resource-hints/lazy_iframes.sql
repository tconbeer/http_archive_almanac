# standardSQL
# Count the number of lazily loaded iframes
create temporary function countlazyiframes(almanac_string string)
returns int64
language js
as '''
try {
    var almanac = JSON.parse(almanac_string)
    if (Array.isArray(almanac) || typeof almanac != 'object') return null;

    var iframes = almanac["iframes"]["iframes"]["nodes"]
    return iframes.filter(i => (i.loading || "").toLowerCase() === "lazy").length
}
catch {
    return null
}
'''
;
with
    iframe_stats_tb as (
        select
            _table_suffix as client,
            countlazyiframes(
                json_extract_scalar(payload, '$._almanac')
            ) as num_lazy_iframes
        from `httparchive.pages.2021_07_01_*`
    )

select
    client,
    num_lazy_iframes,
    count(0) as pages,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from iframe_stats_tb
group by client, num_lazy_iframes
order by client, num_lazy_iframes
