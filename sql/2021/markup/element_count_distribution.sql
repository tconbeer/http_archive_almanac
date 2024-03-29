# standardSQL
# element count distribution per device
# returns all the data we need from _element_count
create temporary function get_element_count_info(element_count_string string)
returns struct<elements_count int64, types_count int64>
language js
as
    '''
var result = {};
try {
    if (!element_count_string) return result;

    var element_count = JSON.parse(element_count_string);

    if (Array.isArray(element_count) || typeof element_count != 'object') return result;

    result.elements_count = Object.values(element_count).reduce((total, freq) => total + (parseInt(freq, 10) || 0), 0);

    result.types_count = Object.keys(element_count).length;

} catch (e) {}
return result;
'''
;

select
    client,
    percentile,
    count(distinct url) as total,

    # total number of elements on a page
    approx_quantiles(element_count_info.elements_count, 1000)[
        offset(percentile * 10)
    ] as elements_count,

    # number of types of elements on a page
    approx_quantiles(element_count_info.types_count, 1000)[
        offset(percentile * 10)
    ] as types_count

from
    (
        select
            _table_suffix as client,
            percentile,
            url,
            get_element_count_info(
                json_extract_scalar(payload, '$._element_count')
            ) as element_count_info
        from
            `httparchive.pages.2021_07_01_*`, unnest([10, 25, 50, 75, 90]) as percentile
    )
group by percentile, client
order by percentile, client
