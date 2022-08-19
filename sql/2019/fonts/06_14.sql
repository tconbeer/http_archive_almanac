# standardSQL
# 06_14: % of pages that declare a font with unicode-range
create temporary function getfonts(css string)
returns array
< string
> language js as '''
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
      if (d.property.toLowerCase() == 'unicode-range') {
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
'''
;

select
    client,
    countif(ranges > 0) as freq,
    total,
    round(countif(ranges > 0) * 100 / total, 2) as pct
from
    (
        select client, sum(array_length(getfonts(css))) as ranges
        from `httparchive.almanac.parsed_css`
        where date = '2019-07-01'
        group by client, page
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (client)
group by client, total
