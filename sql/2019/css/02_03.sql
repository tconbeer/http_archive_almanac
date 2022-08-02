# standardSQL
# 02_03: % of sites that use filter properties
create temporary function usesfilterprop(css string)
returns boolean language js
as '''
try {
  var reduceValues = (values, rule) => {
    if ('rules' in rule) {
      return rule.rules.reduce(reduceValues, values);
    }
    if (!('declarations' in rule)) {
      return values;
    }

    return values.concat(rule.declarations.filter(d => d.property.toLowerCase() == 'filter').map(d => d.value));
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, []).length > 0;
} catch (e) {
  return false;
}
'''
;

select
    client,
    countif(num_stylesheets > 0) as freq,
    total,
    round(countif(num_stylesheets > 0) * 100 / total, 2) as pct
from
    (
        select client, page, countif(usesfilterprop(css)) as num_stylesheets
        from `httparchive.almanac.parsed_css`
        where date = '2019-07-01'
        group by client, page
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by client
    ) using (client)
group by client, total
