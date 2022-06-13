# standardSQL
# 09_30b: Usage of aria-label or aria-labelledby
create temporary function getarialabelusage(payload string)
returns array
< boolean
> language js
as '''
  try {
    var $ = JSON.parse(payload);
    var almanac = JSON.parse($._almanac);
    if (!almanac['input-elements']) {
      return [];
    }

    return almanac['input-elements'].map(function(node) {
      return !!(node['aria-label'] || node['aria-labelledby']);
    });
  } catch (e) {
    return [];
  }
'''
;

select
    _table_suffix as client,
    uses_aria_label,
    count(uses_aria_label) as occurrences,
    sum(count(0)) over (partition by _table_suffix) as total_inputs,
    round(
        count(uses_aria_label) * 100 / sum(count(0)) over (partition by _table_suffix),
        2
    ) as perc_in_all_inputs,
    count(distinct url) as pages_using_aria,
    total as total_pages,
    round(count(distinct url) * 100 / total, 2) as pages_perc
from
    `httparchive.pages.2019_07_01_*`,
    unnest(getarialabelusage(payload)) as uses_aria_label
join
    (
        select _table_suffix, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    )
    using(_table_suffix)
group by client, uses_aria_label, total
order by occurrences desc
