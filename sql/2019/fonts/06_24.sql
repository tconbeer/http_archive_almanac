# standardSQL
# 06_24: % of pages that use specific font-weight integers (eg 555 vs 500)
CREATE TEMPORARY FUNCTION usesVariableWeights(css STRING)
RETURNS INT64 LANGUAGE js AS '''
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
      if (d.property.toLowerCase() == 'font-weight' &&
          !isNaN(parseInt(d.value)) &&
          parseInt(d.value) % 100 > 0) {
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
''';

select
    client,
    count(distinct page) as freq,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from `httparchive.almanac.parsed_css`
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (client)
where date = '2019-07-01'
group by client, total
having sum(usesvariableweights(css)) > 0
