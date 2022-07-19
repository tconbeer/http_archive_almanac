# standardSQL
# Top obsolete elements
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

create temporary function is_obsolete(element string) as (
    element in (
        'applet',
        'acronym',
        'bgsound',
        'dir',
        'frame',
        'frameset',
        'noframes',
        'isindex',
        'keygen',
        'listing',
        'menuitem',
        'nextid',
        'noembed',
        'plaintext',
        'rb',
        'rtc',
        'strike',
        'xmp',
        'basefont',
        'big',
        'blink',
        'center',
        'font',
        'marquee',
        'multicol',
        'nobr',
        'spacer',
        'tt'
    )
)
;

select
    _table_suffix as client,
    element_type as obsolete_element_type,
    count(0) as freq,
    count(distinct url) as pages,
    total as total_pages,
    count(distinct url) / total as pct_pages_with_obsolete_elements,
    count(0) / sum(count(0)) over (
        partition by _table_suffix
    ) as ratio_compared_to_all_obsolete_elements
from `httparchive.pages.2021_07_01_*`
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.pages.2021_07_01_*`
        group by _table_suffix
    )
    using(_table_suffix),
    unnest(
        get_element_types(json_extract_scalar(payload, '$._element_count'))
    ) as element_type
where is_obsolete(element_type)
group by client, total, obsolete_element_type
order by client, pct_pages_with_obsolete_elements desc
