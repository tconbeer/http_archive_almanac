# standardSQL
# percentage/count of pages that contain common elements and roles
create temporary function getusedroles(payload string)
returns array
< string
> language js as '''
try {
  const almanac = JSON.parse(payload);
  return Object.keys(almanac.nodes_using_role.usage_and_count);
} catch (e) {
  return [];
}
'''
;

create temporary function get_element_types(element_count_string string)
returns array
< string
> language js
as '''
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

with
    mappings as (
        select 1 as mapping_id, 'main' as element_type, 'main' as role_type
        union all
        select 2 as mapping_id, 'header' as element_type, 'banner' as role_type
        union all
        select 3 as mapping_id, 'nav' as element_type, 'navigation' as role_type
        union all
        select 4 as mapping_id, 'footer' as element_type, 'contentinfo' as role_type
    ),

    elements as (
        select _table_suffix, url, element_type
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(
                get_element_types(json_extract_scalar(payload, '$._element_count'))
            ) as element_type
        join mappings using (element_type)
    ),

    roles as (
        select _table_suffix, url, role_type
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(
                getusedroles(json_extract_scalar(payload, '$._almanac'))
            ) as role_type
        join mappings using (role_type)
    ),

    base as (
        select
            _table_suffix as client,
            url,
            mapping_id,
            element_type,
            role_type,
            countif(e.element_type is not null) as element_usage,
            countif(r.role_type is not null) as role_usage
        from `httparchive.pages.2021_07_01_*`
        inner join mappings on (true)
        left outer join elements e using (_table_suffix, url, element_type)
        left outer join roles r using (_table_suffix, url, role_type)
        group by client, url, mapping_id, element_type, role_type
    )

select
    client,
    mapping_id,
    element_type,
    role_type,
    count(distinct url) as total_pages,
    countif(element_usage > 0) as element_usage,
    countif(role_usage > 0) as role_usage,
    countif(element_usage > 0 or role_usage > 0) as both_usage,
    countif(element_usage > 0) / count(distinct url) as element_pct,
    countif(role_usage > 0) / count(distinct url) as role_pct,
    countif(element_usage > 0 or role_usage > 0) / count(distinct url) as both_pct
from base
group by client, mapping_id, element_type, role_type
order by client, mapping_id, element_type
