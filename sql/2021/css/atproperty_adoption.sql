# standardSQL
# Percent of pages that use @property
# https://developer.mozilla.org/en-US/docs/Web/CSS/@property
create temp function countatproperties(css string)
returns array<int64>
language js
as '''
try {
  var $ = JSON.parse(css);
  return $.stylesheet.rules.flatMap(rule => {
    if (!rule.selectors) {
      return [];
    }
    return rule.selectors.filter(selector => {
      return selector.startsWith('@property');
    }).length;
  });
} catch (e) {
  return [];
}
'''
;

select
    client,
    countif(uses_atprops) as pages_using_atprops,
    any_value(total_pages) as total_pages,
    countif(uses_atprops) / any_value(total_pages) as pct_pages
from
    (
        select client, sum(num_atprops) > 0 as uses_atprops
        from
            `httparchive.almanac.parsed_css`,
            unnest(countatproperties(css)) as num_atprops
        where date = '2021-07-01'
        group by client, page
    )
join
    (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.summary_pages.2021_07_01_*`
        group by client
    ) using (client)
group by client
