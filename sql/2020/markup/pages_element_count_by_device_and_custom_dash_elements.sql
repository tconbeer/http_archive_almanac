# standardSQL
# % of pages having specific custom elements
# See related: sql/2019/03_Markup/03_03c.sql
# 4.9 seconds for sample 10k
# I tried using this to get the total in a shorter way. Could not get it to be
# accurate, and it was slower!:
# COUNT(COUNT(0)) OVER (PARTITION BY _TABLE_SUFFIX) AS total,
create temp function as_percent(freq float64, total float64)
returns float64
as (round(safe_divide(freq, total), 4))
;

create temporary function get_element_types_with_a_dash(element_count_string string)
returns array<string>
language js
as
    '''
try {
    if (!element_count_string) return []; // 2019 had a few cases

    var element_count = JSON.parse(element_count_string); // should be an object with element type properties with values of how often they are present

    if (Array.isArray(element_count)) return [];
    if (typeof element_count != 'object') return [];

    var r = Object.keys(element_count).filter(e => e.includes('-')); // array of element type names that include a dash
    if (r.length > 0) return r;

    return []; // could be handy having a row showing how many pages do not have one
} catch (e) {
    return [];
}
'''
;

select
    _table_suffix as client,
    element_type_with_a_dash,
    count(distinct url) as pages,
    total,
    as_percent(count(distinct url), total) as pct
from `httparchive.pages.2020_08_01_*`

join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2020_08_01_*`
        group by _table_suffix
    )  # to get an accurate total of pages per device. also seems fast
    using (_table_suffix),
    unnest(
        get_element_types_with_a_dash(json_extract_scalar(payload, '$._element_count'))
    ) as element_type_with_a_dash  # so we end up with pages + element_type_with_a_dash rows
group by client, total, element_type_with_a_dash
order by pct desc, client
limit 1000
