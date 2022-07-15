# standardSQL
# 06_21: % of pages with VF using font-variation-settings
create temporary function usesfontvariationsettings(css string)
returns array
< string
> language js
as '''
try {
  var reduceValues = (values, rule) => {
    if ('rules' in rule) {
      return rule.rules.reduce(reduceValues, values);
    }
    if (!('declarations' in rule)) {
      return values;
    }
    return values.concat(rule.declarations.filter(d => d.property.toLowerCase() == 'font-variation-settings').map(d => d.value));
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, []);
} catch (e) {
  return [];
}
'''
;

select client, count(0) as freq, total, round(count(0) * 100 / total, 2) as pct
from
    (
        select client, page
        from `httparchive.almanac.parsed_css`
        where date = '2019-07-01'
        group by client, page
        having sum(array_length(usesfontvariationsettings(css))) > 0
    )
join
    (
        select client, page
        from `httparchive.almanac.requests`
        where
            date = '2019-07-01'
            and type = 'font'
            and json_extract_scalar(payload, '$._font_details.table_sizes.gvar')
            is not null
        group by client, page
    )
    using
    (client, page)
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by client
    )
    using
    (client)
group by client, total
