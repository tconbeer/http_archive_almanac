# standardSQL
# input attributes
create temporary function getinputattributes(payload string)
returns array
< string
> language js as '''
  var attrs = [];
  try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);
    almanac['input-elements'] && almanac['input-elements'].forEach(function(node) {
        Object.keys(node).forEach(function(attr) {
            if (attr != 'tagName') attrs.push(attr);
        });
    });
    return attrs;
  } catch (e) {
    return [];
  }
'''
;

create temporary function hasinputs(payload string)
returns boolean language js as '''
  try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);

    if (!almanac['input-elements']) {
      return false;
    }

    return almanac['input-elements'].length;
  } catch (e) {
    return 0;
  }
'''
;

select
    total_pages_with_inputs,
    sum(count(0)) over () as total_inputs,
    input_attributes,

    count(input_attributes) as occurence,
    count(distinct url) as total_pages_using,
    round(count(input_attributes) * 100 / sum(count(0)) over (), 2) as occurence_perc,
    round(count(distinct url) * 100 / total_pages_with_inputs, 2) as perc_of_pages_using
from
    `httparchive.pages.2019_07_01_mobile`,
    unnest(getinputattributes(payload)) as input_attributes,
    (
        select countif(hasinputs(payload)) as total_pages_with_inputs
        from `httparchive.pages.2019_07_01_mobile`
    )
group by input_attributes, total_pages_with_inputs
order by perc_of_pages_using desc
limit 1000
