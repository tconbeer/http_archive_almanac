# standardSQL
# 06_44: % of pages that use font-display
CREATE TEMPORARY FUNCTION getFontDisplay(css STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
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

    rule.declarations.forEach(d => {
      if (d.property.toLowerCase() == 'font-display') {
        values.push(d.value);
      }
    });
    return values;
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, []);
} catch (e) {
  return [];
}
''';

select
    client,
    font_display,
    count(distinct page) as freq,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from `httparchive.almanac.parsed_css`, unnest(getfontdisplay(css)) as font_display
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (client)
where date = '2019-07-01'
group by client, total, font_display
order by freq / total desc
