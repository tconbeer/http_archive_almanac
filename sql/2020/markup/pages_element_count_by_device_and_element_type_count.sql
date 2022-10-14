# standardSQL
# frequency of the number of element types used on a page
# returns all the data we need from _element_count
CREATE TEMPORARY FUNCTION get_element_type_COUNT(element_count_string STRING)
RETURNS INT64 LANGUAGE js AS '''
try {
    if (!element_count_string) return null;

    var element_count = JSON.parse(element_count_string);

    if (Array.isArray(element_count) || typeof element_count != 'object') return null;

    return Object.keys(element_count).length;

} catch (e) {}
return null;
''';

select
    _table_suffix as client,
    get_element_type_count(
        json_extract_scalar(payload, '$._element_count')
    ) as element_types,
    count(0) as freq
from `httparchive.pages.2020_08_01_*`
group by element_types, client
order by element_types, client
