# Sheet: CSS Ruby
# standardSQL
# Adoption of CSS Ruby
create temporary function usesruby(css string)
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

    const rubyProperties = new Set(['ruby-position', 'ruby-align', 'ruby-merge', 'ruby-overhang']);
    const rubyDisplayValues = new Set(['ruby', 'ruby-base', 'ruby-text', 'ruby-base-container', 'ruby-text-container']);
    return values.concat(rule.declarations.filter(d => {
      return rubyProperties.has(d.property) || (d.property == 'display' && rubyDisplayValues.has(d.value));
    }));
  };
  var $ = JSON.parse(css);
  return $.stylesheet.rules.reduce(reduceValues, []).length > 0;
} catch (e) {
  return false;
}
'''
;

select client, countif(uses_ruby) as freq, total, countif(uses_ruby) / total as pct
from
    (
        select client, page, countif(usesruby(css)) > 0 as uses_ruby
        from `httparchive.almanac.parsed_css`
        where date = '2021-07-01'
        group by client, page
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2021_07_01_*`
        group by client
    )
    using
    (client)
group by client, total
