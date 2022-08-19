# standardSQL
# 06_28: Popularity of font-variation-settings axes
create temporary function getfontvariationsettings(css string)
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
    return values.concat(rule.declarations.filter(d => d.property.toLowerCase() == 'font-variation-settings').map(d => d.value));
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
    regexp_extract(lower(value), '[\'"]([\\w]{4})[\'"]') as axis,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from
    `httparchive.almanac.parsed_css`,
    unnest(getfontvariationsettings(css)) as values,
    unnest(split(values, ',')) as value
where date = '2019-07-01'
group by client, axis
having axis is not null
order by freq / total desc
