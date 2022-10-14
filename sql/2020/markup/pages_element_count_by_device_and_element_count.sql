# standardSQL
# frequency of the number of element used on a page
# returns all the data we need from _element_count
CREATE TEMPORARY FUNCTION get_element_COUNT(element_count_string STRING)
RETURNS INT64 LANGUAGE js AS '''
try {
    if (!element_count_string) return null;

    var element_count = JSON.parse(element_count_string);

    if (Array.isArray(element_count) || typeof element_count != 'object') return null;

    return Object.values(element_count).reduce((total, freq) => total + (parseInt(freq, 10) || 0), 0);

} catch (e) {}
return null;
''';

select
    _table_suffix as client,
    get_element_count(json_extract_scalar(payload, '$._element_count')) as elements,
    count(0) as freq
from `httparchive.pages.2020_08_01_*`
group by elements, client
having elements <= 2000
order by elements, client
