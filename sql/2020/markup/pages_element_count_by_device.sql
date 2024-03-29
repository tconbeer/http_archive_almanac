# standardSQL
# pages element_count metrics grouped by device
# helper to create percent fields
create temp function as_percent(freq float64, total float64)
returns float64
as (round(safe_divide(freq, total), 4))
;

# returns all the data we need from _element_count
create temporary function get_element_count_info(element_count_string string)
returns
    struct<
        contains_custom_element bool,
        contains_obsolete_element bool,
        contains_details_element bool,
        contains_summary_element bool
    >
language js
as
    '''
var result = {};
try {
    if (!element_count_string) return result;

    var element_count = JSON.parse(element_count_string);

    if (Array.isArray(element_count) || typeof element_count != 'object') return result;

    result.contains_custom_element = Object.keys(element_count).filter(e => e.includes('-')).length > 0;
    result.contains_details_element = Object.keys(element_count).filter(e => e ==='details').length > 0;
    result.contains_summary_element = Object.keys(element_count).filter(e => e ==='summary').length > 0;

    var obsoleteElements = new Set(["applet", "acronym", "bgsound", "dir", "frame", "frameset", "noframes", "isindex", "keygen", "listing", "menuitem", "nextid", "noembed", "plaintext", "rb", "rtc", "strike", "xmp", "basefont", "big", "blink", "center", "font", "marquee", "multicol", "nobr", "spacer", "tt"]);

    result.contains_obsolete_element = !!Object.keys(element_count).find(e => {
        return obsoleteElements.has(e);
    });

} catch (e) {}
return result;
'''
;

select
    client,
    count(0) as total,

    # % of pages with obsolete elements related to M216
    as_percent(
        countif(element_count_info.contains_obsolete_element), count(0)
    ) as pct_contains_obsolete_element_m216,

    # % of pages with custom elements ("slang") related to M242
    as_percent(
        countif(element_count_info.contains_custom_element), count(0)
    ) as pct_contains_custom_element_m242,

    # % of pages with details and summary elements M214
    as_percent(
        countif(
            element_count_info.contains_details_element
            and element_count_info.contains_summary_element
        ),
        count(0)
    ) as pct_contains_details_and_summary_element_m214

from
    (
        select
            _table_suffix as client,
            get_element_count_info(
                json_extract_scalar(payload, '$._element_count')
            ) as element_count_info
        from `httparchive.pages.2020_08_01_*`
    )
group by client
