# standardSQL
# 02_08b: % of selectors that use classes or IDs
create temporary function getselectortype(css string)
returns struct<class int64, id int64, total int64>
language js
as '''
var types = {
  'class': 0,
  'id': 0,
  'total': 0
};
try {
  var reduceValues = (values, rule) => {
    if ('rules' in rule) {
      return rule.rules.reduce(reduceValues, values);
    }
    var selectors = rule.selectors || rule.selector && [rule.selector];
    if (!selectors) {
      return values;
    }

    selectors.forEach(selector => {
      if (selector.includes('.')) {
        values.class++;
      }
      if (selector.includes(`#`)) {
        values.id++;
      }
      values.total++;
    });
    return values;
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, types);
} catch (e) {
  return types;
}
'''
;

select
    client,
    sum(type.class) as class,
    sum(type.id) as id,
    sum(type.total) as selectors,
    round(sum(type.class) * 100 / sum(type.total), 2) as pct_class,
    round(sum(type.id) * 100 / sum(type.total), 2) as pct_id
from
    (
        select client, getselectortype(css) as type
        from `httparchive.almanac.parsed_css`
        where date = '2019-07-01'
    )
group by client
