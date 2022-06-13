# standardSQL
# input attributes occurence defined set % (minus placeholder and required)
create temporary function getinputstats(payload string)
returns struct < has_advanced_attributes boolean,
total_inputs int64
> language js
as '''
  try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);
    var found_index = almanac['input-elements'].findIndex(node => {
        var search = Object.keys(node).findIndex(attr => {
            if(attr.match(/(autocomplete|min|max|pattern|step)/i)) {
                return true;
            }
        });

        return search >= 0 ? true : false;
    });

    return {
      has_advanced_attributes: found_index >= 0 ? true : false,
      total_inputs: almanac['input-elements'].length
    };
  } catch (e) {
    return {
      has_advanced_attributes: false,
      total_inputs: 0
    };
  }
'''
;

select
    count(0) as count,
    countif(input_stats.total_inputs > 0) as total_applicable,

    countif(input_stats.has_advanced_attributes) as total_pages_using,
    round(
        countif(input_stats.has_advanced_attributes) * 100 / countif(
            input_stats.total_inputs > 0
        ),
        2
    ) as occurence_perc
from
    (
        select getinputstats(payload) as input_stats
        from `httparchive.pages.2019_07_01_mobile`
    )
