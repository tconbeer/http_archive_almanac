# standardSQL
# pages almanac metrics grouped by device and element attribute use (frequency)
create temporary function get_almanac_attribute_info(almanac_string string)
returns
    array<
        struct<
            name string,
            freq int64 >> language js
            as
                '''
try {
    var almanac = JSON.parse(almanac_string);

    if (Array.isArray(almanac) || typeof almanac != 'object') return [];

    if (almanac.attributes_used_on_elements) {
      return Object.entries(almanac.attributes_used_on_elements).map(([name, freq]) => ({name, freq}));
    }

} catch (e) {

}
return [];
'''
;

select
    _table_suffix as client,
    almanac_attribute_info.name,
    sum(almanac_attribute_info.freq) as freq,  # total count from all pages
    sum(sum(almanac_attribute_info.freq)) over (partition by _table_suffix) as total,
    sum(almanac_attribute_info.freq) / sum(sum(almanac_attribute_info.freq)) over (
        partition by _table_suffix
    ) as pct_ratio
from
    `httparchive.pages.2021_07_01_*`,
    unnest(
        get_almanac_attribute_info(json_extract_scalar(payload, '$._almanac'))
    ) as almanac_attribute_info
group by client, almanac_attribute_info.name
order by pct_ratio desc, client, freq desc
limit 1000
