# standardSQL
# 06_16: % of pages that declare a font with local()
create temporary function countlocalsrc(css string)
returns int64 language js as '''
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
      if (d.property.toLowerCase() == 'src' && d.value.includes('local(')) {
        values++;
      }
    });
    return values;
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, 0);
} catch (e) {
  return 0;
}
'''
;

select
    client,
    countif(local > 0) as freq,
    total,
    round(countif(local > 0) * 100 / total, 2) as pct
from
    (
        select client, sum(countlocalsrc(css)) as local
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
