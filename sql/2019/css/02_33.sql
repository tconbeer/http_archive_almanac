# standardSQL
# 02_33: Distribution of duplicate color values per page
create temporary function getcolors(css string)
returns array
< string
> language js
as '''
try {
  var reduceValues = (values, rule) => {
    if ('rules' in rule) {
      return rule.rules.reduce(reduceValues, values);
    }
    if (!('declarations' in rule)) {
      return values;
    }

    return values.concat(rule.declarations.filter(d => d.property.toLowerCase() == 'color').map(d => d.value));
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, []);
} catch (e) {
  return [];
}
'''
;

select
    client,
    approx_quantiles(duplicate_colors, 1000) [offset (100)] as p10,
    approx_quantiles(duplicate_colors, 1000) [offset (250)] as p25,
    approx_quantiles(duplicate_colors, 1000) [offset (500)] as p50,
    approx_quantiles(duplicate_colors, 1000) [offset (750)] as p75,
    approx_quantiles(duplicate_colors, 1000) [offset (900)] as p90
from
    (
        select client, page, countif(freq > 1) as duplicate_colors
        from
            (
                select client, page, value, count(0) as freq
                from `httparchive.almanac.parsed_css`
                left join unnest(getcolors(css)) as value
                where date = '2019-07-01'
                group by client, page, value
            )
        group by client, page
    )
group by client
