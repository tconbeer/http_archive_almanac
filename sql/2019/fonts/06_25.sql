# standardSQL
# 06_25: % of pages that use @supports font-variant-*
create temporary function checkssupports(css string)
returns array
< string
> language js
as '''
try {
  var reduceValues = (values, rule) => {
    if (rule.type == 'supports' && rule.supports.toLowerCase().includes('font-variation-settings')) {
      values.push(rule.supports.toLowerCase());
    }
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
    count(distinct page) as freq,
    total,
    round(count(distinct page) * 100 / total, 2) as pct
from `httparchive.almanac.parsed_css`
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    )
    using
    (client)
where date = '2019-07-01' and array_length(checkssupports(css)) > 0
group by client, total
