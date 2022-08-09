# standardSQL
# 06_36-38: Top declared font formats
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
    rule.declarations.filter(d => d.property.toLowerCase() == 'src').map(d => d.value).forEach(srcs => {
      srcs.split(',').filter(src => re.test(src)).forEach(src => {
        values.push(src.toLowerCase().match(re)[1]);
      });
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
    format,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from `httparchive.almanac.parsed_css`, unnest(getfontformats(css)) as format
where date = '2019-07-01'
group by client, format
order by freq / total desc
