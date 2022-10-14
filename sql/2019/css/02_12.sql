# standardSQL
# 02_12: % of sites that use each dir value
CREATE TEMPORARY FUNCTION getDirValues(css STRING)
RETURNS ARRAY<STRING> LANGUAGE js AS '''
try {
  var reduceValues = (values, rule) => {
    if ('rules' in rule) {
      return rule.rules.reduce(reduceValues, values);
    }
    if (!('declarations' in rule)) {
      return values;
    }

    rule.declarations.forEach(d => {
      if (d.property != 'direction') {
        return;
      }
      if (d.value.match(/rtl/i)) {
        values['rtl'] = true;
      }
      if (d.value.match(/ltr/i)) {
        values['ltr'] = true;
      }
    });
    return values;
  };
  var $ = JSON.parse(css);
  return Object.keys($.stylesheet.rules.reduce(reduceValues, {}));
} catch (e) {
  return [];
}
''';

select client, direction, freq, total, round(freq * 100 / total, 2) as pct
from
    (
        select client, direction, count(distinct page) as freq
        from `httparchive.almanac.parsed_css`, unnest(getdirvalues(css)) as direction
        where date = '2019-07-01'
        group by client, direction
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by client
    ) using (client)
order by freq / total desc
