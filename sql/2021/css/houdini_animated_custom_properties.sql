# standardSQL
CREATE TEMPORARY FUNCTION getAnimatedCustomProperties(css STRING)
RETURNS ARRAY<STRING>
LANGUAGE js
OPTIONS (library = "gs://httparchive/lib/css-utils.js")
AS '''
try {
  var ast = JSON.parse(css);
  let ret = new Set();

  walkRules(ast, rule => {
    walkDeclarations(rule.keyframes, ({property, value}) => {
      ret.add(property);
    }, {
      properties: /^--/
    });
  }, {
    type: "keyframes"
  });

  return [...ret];
} catch (e) {
  return [];
}
''';

select distinct
    client,
    custom_property,
    count(distinct page) over (partition by client, custom_property) as pages,
    count(distinct page) over (partition by client) as total_pages,
    count(distinct page) over (partition by client, custom_property)
    / count(distinct page) over (partition by client) as pct_pages,
    count(0) over (partition by client, custom_property) as freq,
    count(0) over (partition by client) as total,
    count(0) over (partition by client, custom_property)
    / count(0) over (partition by client) as pct
from
    `httparchive.almanac.parsed_css`,
    unnest(getanimatedcustomproperties(css)) as custom_property
where date = '2021-07-01'
order by pct desc
