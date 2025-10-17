# standardSQL
# 06_28b: Popularity of font-variation-settings values
create temporary function getfontvariationsettings(css string)
returns array<string>
language js
as
    '''
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
    replace(trim(lower(setting)), "'", '"') as setting,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from
    `httparchive.almanac.parsed_css`,
    unnest(getfontvariationsettings(css)) as value,
    unnest(split(value, ',')) as setting
where date = '2019-07-01'
group by client, setting
order by freq / total desc
