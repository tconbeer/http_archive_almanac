# standardSQL
# Count the number of lazily loaded iframes
# returns true/false if the page has an iframe with `loading="lazy"` or null if the
# page has no iframes
create temporary function haslazyloadediframe(almanac_string string)
returns bool
language js as '''
try {
    var almanac = JSON.parse(almanac_string)
    if (Array.isArray(almanac) || typeof almanac != 'object') return null;

    var iframes = almanac["iframes"]["iframes"]["nodes"]

    if (iframes.length) {
        return !!iframes.filter(i => (i.loading || "").toLowerCase() === "lazy").length
    }

    return null;
}
catch {
    return null
}
'''
;

select
    client,
    countif(has_lazy_iframes) as is_lazy,
    countif(has_lazy_iframes is not null) as has_iframe,
    countif(has_lazy_iframes) / countif(has_lazy_iframes is not null) as pct,
    count(0) as total
from
    (
        select
            _table_suffix as client,
            haslazyloadediframe(
                json_extract_scalar(payload, '$._almanac')
            ) as has_lazy_iframes
        from `httparchive.pages.2021_07_01_*`
    )
group by client
order by client
