# standardSQL
# 12_12: Popular input types
create temporary function getinputtypes(payload string)
returns array
< string
> language js as '''
  try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);
    return almanac['input-elements'] && almanac['input-elements'].map(function(node) {
        return node.type.toLowerCase();
    });
  } catch (e) {
    return [];
  }
'''
;

select
    input_type,
    count(input_type) as occurence,
    round(count(input_type) * 100 / sum(count(0)) over (), 2) as occurence_perc,
    count(distinct url) as pages,
    total as total_pages,
    round(count(distinct url) * 100 / total, 2) as pages_perc
from
    `httparchive.pages.2019_07_01_mobile`,
    (select count(0) as total from `httparchive.summary_pages.2019_07_01_mobile`),
    unnest(getinputtypes(payload)) as input_type
group by input_type, total
order by occurence desc
