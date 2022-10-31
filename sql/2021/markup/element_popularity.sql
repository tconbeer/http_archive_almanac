# standardSQL
# percentage/count of pages that contain each element
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
    count(distinct url) / total as pct
from `httparchive.pages.2021_07_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    ) using (_table_suffix),
    unnest(
        get_element_types(json_extract_scalar(payload, '$._element_count'))
    ) as element_type
group by client, total, element_type
order by pct desc, client, pages desc
limit 1000
