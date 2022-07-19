# standardSQL
# Distribution of @property rules per page
create temp function countatproperties(css string) returns array
< int64
> language js as '''
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
    percentile,
    client,
    approx_quantiles(atprops_per_page, 1000)[
        offset(percentile * 10)
    ] as atprops_per_page
from
    (
        select client, sum(num_atprops) as atprops_per_page
        from
            `httparchive.almanac.parsed_css`,
            unnest(countatproperties(css)) as num_atprops
        where date = '2021-07-01'
        group by client, page
    ),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
where atprops_per_page > 0
group by percentile, client
order by percentile, client
