# standardSQL
# 02_40: Distribution of distinct margin values per page
create temporary function getmarginvalues(css string)
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

    return values.concat(rule.declarations.filter(d => d.property.toLowerCase().startsWith('margin')).map(d => d.value));
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
    approx_quantiles(margins, 1000) [offset (100)] as p10,
    approx_quantiles(margins, 1000) [offset (250)] as p25,
    approx_quantiles(margins, 1000) [offset (500)] as p50,
    approx_quantiles(margins, 1000) [offset (750)] as p75,
    approx_quantiles(margins, 1000) [offset (900)] as p90
from
    (
        select client, count(distinct value) as margins
        from `httparchive.almanac.parsed_css`
        left join unnest(getmarginvalues(css)) as value
        where date = '2019-07-01'
        group by client, page
    )
group by client
