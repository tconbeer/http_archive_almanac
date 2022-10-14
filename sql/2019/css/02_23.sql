# standardSQL
# 02_23: Popular fonts
CREATE TEMPORARY FUNCTION getFontFamilies(css STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
try {
  var $ = JSON.parse(css);
  return $.stylesheet.rules.filter(rule => rule.type == 'font-face').map(rule => {
    var family = rule.declarations && rule.declarations.find(d => d.property == 'font-family');
    return family && family.value.replace(/[\'"]/g, '');
  }).filter(family => family);
} catch (e) {
  return [];
}
''';

select
    client,
    font_family,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct
from `httparchive.almanac.parsed_css`, unnest(getfontfamilies(css)) as font_family
where date = '2019-07-01'
group by client, font_family
order by freq / total desc
