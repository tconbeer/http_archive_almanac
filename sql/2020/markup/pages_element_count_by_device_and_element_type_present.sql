# standardSQL
# how many pages contain an element by element and device M241
# See related: sql/2019/03_Markup/03_02a.sql
create temp function as_percent(freq float64, total float64)
returns float64
as (round(safe_divide(freq, total), 4))
;

create temporary function get_element_types(element_count_string string)
returns array<string>
language js
as
    '''
try {
    if (!element_count_string) return []; // 2019 had a few cases

    var element_count = JSON.parse(element_count_string); // should be an object with element type properties with values of how often they are present

    if (Array.isArray(element_count)) return [];
    if (typeof element_count != 'object') return [];

    return Object.keys(element_count);
} catch (e) {
    return [];
}
'''
;

select
    _table_suffix as client,
    element_type,
    count(distinct url) as pages,
    total,
    as_percent(count(distinct url), total) as pct_m241
from `httparchive.pages.2020_08_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2020_08_01_*`
        # to get an accurate total of pages per device. also seems fast
        group by _table_suffix
    ) using (_table_suffix),
    unnest(
        get_element_types(json_extract_scalar(payload, '$._element_count'))
    ) as element_type
group by client, total, element_type
order by pages / total desc, client
limit 1000
