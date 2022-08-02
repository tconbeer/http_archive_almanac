# standardSQL
# 02_08: % of sites that use classes or IDs in selectors
create temporary function getselectortype(css string)
returns struct < class boolean,
id boolean
> language js as '''
try {
  var reduceValues = (values, rule) => {
    if ('rules' in rule) {
      return rule.rules.reduce(reduceValues, values);
    }
    var selectors = rule.selectors || rule.selector && [rule.selector];
    if (!selectors) {
      return values;
    }

    selectors.forEach(selector => {
      if (selector.includes('.')) {
        values['class'] = true;
      }
      if (selector.includes(`#`)) {
        values['id'] = true;
      }
    });
    return values;
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, {});
} catch (e) {
  return {};
}
'''
;

select
    client,
    countif(class > 0) as freq_class,
    countif(id > 0) as freq_id,
    total,
    round(countif(class > 0) * 100 / total, 2) as pct_class,
    round(countif(id > 0) * 100 / total, 2) as pct_id
from
    (
        select client, countif(type.class) as class, countif(type.id) as id
        from
            (
                select client, page, getselectortype(css) as type
                from `httparchive.almanac.parsed_css`
                where date = '2019-07-01'
            )
        group by client, page
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by client
    ) using (client)
group by client, total
