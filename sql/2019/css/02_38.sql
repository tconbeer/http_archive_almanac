# standardSQL
# 02_38: Top numeric z-index values
CREATE TEMPORARY FUNCTION getNumericZIndexValues(css STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
try {
  var reduceValues = (values, rule) => {
    if ('rules' in rule) {
      return rule.rules.reduce(reduceValues, values);
    }
    if (!('declarations' in rule)) {
      return values;
    }

    return values.concat(rule.declarations.filter(d => d.property.toLowerCase() == 'z-index' && !isNaN(parseInt(d.value))).map(d => parseInt(d.value)));
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, []);
} catch (e) {
  return [];
}
''';

select
    client,
    value,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from `httparchive.almanac.parsed_css`, unnest(getnumericzindexvalues(css)) as value
where date = '2019-07-01'
group by client, value
order by freq / total desc
