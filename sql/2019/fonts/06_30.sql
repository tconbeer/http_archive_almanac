# standardSQL
# 06_30: VF variation axes used in concert
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
    var re = /['"](\\w{4})["']/;
    return values.concat(rule.declarations.filter(d => d.property.toLowerCase() == 'font-variation-settings').map(d => {
      // Convert something like `"opsz" 15, "oval" 200` into `opsz, oval`
      return d.value.toLowerCase().split(',').filter(axis => re.test(axis)).map(axis => axis.match(re)[1]).sort().join(', ');
    }));
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
    common_axes,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from
    `httparchive.almanac.parsed_css`,
    unnest(getfontvariationsettings(css)) as common_axes
where date = '2019-07-01'
group by client, common_axes
having common_axes is not null and common_axes != ''
order by freq / total desc
