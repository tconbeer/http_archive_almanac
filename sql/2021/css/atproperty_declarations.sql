# standardSQL
# Adoption of @property declarations
CREATE TEMP FUNCTION getAtPropertyValues(css STRING) RETURNS ARRAY<STRUCT<syntax STRING, inherits STRING, `initial-value` STRING>> LANGUAGE js AS '''
try {
  var $ = JSON.parse(css);
  return $.stylesheet.rules.flatMap(rule => {
    if (!rule.selectors) {
      return [];
    }

    var isAtProperty = rule.selectors.filter(selector => {
      return selector.startsWith('@property');
    }).length;

    if (!isAtProperty) {
      return [];
    }

    return Object.fromEntries(rule.declarations.map(declaration => {
      return [declaration.property, declaration.value];
    }));
  });
} catch (e) {
  return [];
}
''';

select
    client,
    syntax,
    inherits,
    initial_value,
    count(distinct page) as pages,
    any_value(total_pages) as total_pages,
    count(distinct page) / any_value(total_pages) as pct_pages,
    count(0) as freq,
    sum(count(0)) over (partition by client) as total,
    count(0) / sum(count(0)) over (partition by client) as pct
from
    (
        select
            client,
            page,
            regexp_replace(atproperty.syntax, r'[\'"]', '') as syntax,
            atproperty.inherits,
            atproperty.`initial-value` as initial_value
        from
            `httparchive.almanac.parsed_css`,
            unnest(getatpropertyvalues(css)) as atproperty
        where date = '2021-07-01'
    )
join
    (
        select _table_suffix as client, count(0) as total_pages
        from `httparchive.summary_pages.2021_07_01_*`
        group by client
    ) using (client)
group by client, syntax, inherits, initial_value
