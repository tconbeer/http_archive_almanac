# standardSQL
CREATE TEMPORARY FUNCTION hasMulticol(css STRING)
RETURNS BOOLEAN
LANGUAGE js
OPTIONS (library = "gs://httparchive/lib/css-utils.js")
AS '''
try {
  const ast = JSON.parse(css);
  let props = countDeclarationsByProperty(ast.stylesheet.rules, {properties: /^column[s-]/});
  return Object.keys(props).length > 0;
} catch (e) {
  return false;
}
''';

select
    client,
    countif(multicol) as pages_with_multicol,
    total,
    countif(multicol) / total as pct
from
    (
        select client, page, countif(hasmulticol(css)) > 0 as multicol
        from `httparchive.almanac.parsed_css`
        where date = '2021-07-01'
        group by client, page
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2021_07_01_*`
        group by client
    ) using (client)
group by client, total
