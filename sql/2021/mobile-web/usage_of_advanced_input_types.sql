# standardSQL
# Usage of advanced input types
# color, date, datetime-local, email, month, number, range, reset, search, tel, time,
# url, week, datalist
create temporary function getinputstats(payload string)
returns struct<found_advanced_types boolean, total_inputs int64>
language js
as
    '''
try {
  const almanac = JSON.parse(payload);
  const found_index = almanac.input_elements.nodes.findIndex(node => {
    if(node.type && node.type.match(/(color|date|datetime-local|email|month|number|range|reset|search|tel|time|url|week|datalist)/i)) {
      return true;
    }
  });

  return {
    found_advanced_types: found_index >= 0,
    total_inputs: almanac.input_elements.nodes.length,
  };
} catch (e) {
  return {
    found_advanced_types: false,
    total_inputs: 0,
  };
}
'''
;

select
    count(0) as total_pages,
    countif(input_stats.total_inputs > 0) as total_applicable_pages,
    countif(input_stats.found_advanced_types) as total_pages_using,
    countif(input_stats.found_advanced_types)
    / countif(input_stats.total_inputs > 0) as occurence_pct
from
    (
        select getinputstats(json_extract_scalar(payload, '$._almanac')) as input_stats
        from `httparchive.pages.2021_07_01_mobile`
    )
