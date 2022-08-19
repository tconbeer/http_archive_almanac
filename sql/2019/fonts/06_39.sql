# standardSQL
# 06_39-41: Font formats declared together
create temporary function getfontformats(css string)
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
    if (rule.type != 'font-face') {
      return values;
    }
    // From `url(basic-sans-serif.ttf) format("truetype")` get `truetype`.
    var re = /format\\(["']?(\\w+)['"]?\\)/;
    return values.concat(rule.declarations.filter(d => d.property.toLowerCase() == 'src').map(d => {
      // Convert `format(woff), format(svg)` into `svg, woff`
      return d.value.toLowerCase().split(',').filter(src => re.test(src)).map(src => src.match(re)[1]).sort().join(', ');
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
    formats,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from `httparchive.almanac.parsed_css`, unnest(getfontformats(css)) as formats
where date = '2019-07-01'
group by client, formats
having formats is not null and formats != ''
order by freq / total desc
