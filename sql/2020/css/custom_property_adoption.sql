# standardSQL
# % of sites that use custom properties.
# Same query as 2019, to compare trend
create temporary function usescustomprops(css string)
returns boolean language js as '''
try {
  var reduceValues = (values, rule) => {
    if ('rules' in rule) {
      return rule.rules.reduce(reduceValues, values);
    }
    if (!('declarations' in rule)) {
      return values;
    }

    return values.concat(rule.declarations.filter(d => d.property.startsWith(`--`)));
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
        select client, page, countif(usescustomprops(css)) as num_stylesheets
        from `httparchive.almanac.parsed_css`
        where date = '2020-08-01'
        group by client, page
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by client
    )
    using
    (client)
group by client, total
