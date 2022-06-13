# standardSQL
# input types occurence prefined set %
create temporary function getinputstats(payload string)
returns struct < found_advanced_types boolean,
total_inputs int64
> language js
as '''
  try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);
    var found_index = almanac['input-elements'].findIndex(node => {
        if(node.type && node.type.match(/(color|date|datetime-local|email|month|number|range|reset|search|tel|time|url|week|datalist)/i)) {
            return true;
        }
    });

    return {
      found_advanced_types: found_index >= 0 ? true : false,
      total_inputs: almanac['input-elements'].length
    };
  } catch (e) {
    return {
      found_advanced_types: false,
      total_inputs: 0
    };
  }
'''
;

select
    count(0) as count,
    countif(input_stats.total_inputs > 0) as total_applicable,

    countif(input_stats.found_advanced_types) as total_pages_using,
    round(
        countif(input_stats.found_advanced_types) * 100 / countif(
            input_stats.total_inputs > 0
        ),
        2
    ) as occurence_perc
from
    (
        select getinputstats(payload) as input_stats
        from `httparchive.pages.2019_07_01_mobile`
    )
