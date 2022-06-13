# standardSQL
# 02_46: Distribution of selector class length
create temporary function getclasschainlengths(css string)
returns array
< int64
> language js
as '''
try {
  var reduceValues = (values, rule) => {
    if ('rules' in rule) {
      return rule.rules.reduce(reduceValues, values);
    }
    var selectors = rule.selectors || rule.selector && [rule.selector];
    if (!selectors) {
      return values;
    }

    rule.selectors.forEach(selector => {
      if (selector.includes('.')) {
        selector.split(' ').forEach(descendent => {
          var chainLength = descendent.split('.').length - 1;
          values.push(chainLength);
        });
      }
    });
    return values;
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
    approx_quantiles(classes, 1000) [offset (100)] as p10,
    approx_quantiles(classes, 1000) [offset (250)] as p25,
    approx_quantiles(classes, 1000) [offset (500)] as p50,
    approx_quantiles(classes, 1000) [offset (750)] as p75,
    approx_quantiles(classes, 1000) [offset (900)] as p90
from `httparchive.almanac.parsed_css`
left join unnest(getclasschainlengths(css)) as classes
where date = '2019-07-01'
group by client
