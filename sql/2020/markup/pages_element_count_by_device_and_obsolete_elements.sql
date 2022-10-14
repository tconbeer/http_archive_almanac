# standardSQL
# Top obsolete elements M216
# See related: sql/2019/03_Markup/03_01b.sql
CREATE TEMP FUNCTION AS_PERCENT (freq FLOAT64, total FLOAT64) RETURNS FLOAT64 AS (
  ROUND(SAFE_DIVIDE(freq, total), 4)
);

CREATE TEMPORARY FUNCTION get_element_types(element_count_string STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
try {
    if (!element_count_string) return []; // 2019 had a few cases

    var element_count = JSON.parse(element_count_string); // should be an object with element type properties with values of how often they are present

    if (Array.isArray(element_count)) return [];
    if (typeof element_count != 'object') return [];

    return Object.keys(element_count);
} catch (e) {
    return [];
}
''';

CREATE TEMPORARY FUNCTION is_obsolete(element STRING) AS (
  element IN ('applet', 'acronym', 'bgsound', 'dir', 'frame', 'frameset', 'noframes', 'isindex', 'keygen', 'listing', 'menuitem', 'nextid', 'noembed', 'plaintext', 'rb', 'rtc', 'strike', 'xmp', 'basefont', 'big', 'blink', 'center', 'font', 'marquee', 'multicol', 'nobr', 'spacer', 'tt')
);

select
    _table_suffix as client,
    element_type as obsolete_element_type,
    count(0) as freq,
    as_percent(count(0), total) as pct_pages_with_obsolete_elements,
    as_percent(
        count(0), sum(count(0)) over (partition by _table_suffix)
    ) as ratio_compared_to_all_obsolete_elements
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
where is_obsolete(element_type)
group by client, total, obsolete_element_type
order by pct_pages_with_obsolete_elements desc, client
