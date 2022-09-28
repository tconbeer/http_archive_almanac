# standardSQL
# 02_41: Distribution of transitions per page
create temporary function gettransitions(css string)
returns int64 language js
as '''
try {
  var reduceValues = (values, rule) => {
    if ('rules' in rule) {
      return rule.rules.reduce(reduceValues, values);
    }
    if (!('declarations' in rule)) {
      return values;
    }

    return values + !!rule.declarations.find(d => d.property.toLowerCase().startsWith('transition'));
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, 0);
} catch (e) {
  return 0;
}
'''
;

select
    client,
    approx_quantiles(transitions, 1000)[offset(100)] as p10,
    approx_quantiles(transitions, 1000)[offset(250)] as p25,
    approx_quantiles(transitions, 1000)[offset(500)] as p50,
    approx_quantiles(transitions, 1000)[offset(750)] as p75,
    approx_quantiles(transitions, 1000)[offset(900)] as p90
from
    (
        select client, sum(gettransitions(css)) as transitions
        from `httparchive.almanac.parsed_css`
        where date = '2019-07-01'
        group by client, page
    )
group by client
