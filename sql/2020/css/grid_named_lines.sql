# standardSQL
create temporary function hasgridnamedlines(css string)
returns boolean
language js
options (library = "gs://httparchive/lib/css-utils.js")
as
    '''
try {
  const ast = JSON.parse(css);
  let props = countDeclarationsByProperty(ast.stylesheet.rules, {properties: /^grid($|\\-)/, values: /\\[([\\w-]+)\\]/});
  return Object.keys(props).length > 0;
} catch (e) {
  return false;
}
'''
;

select
    client,
    countif(grid_named_lines) as pages_with_grid_named_lines,
    total,
    countif(grid_named_lines) / total as pct
from
    (
        select client, page, countif(hasgridnamedlines(css)) > 0 as grid_named_lines
        from `httparchive.almanac.parsed_css`
        where date = '2020-08-01'
        group by client, page
    )
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2020_08_01_*`
        group by client
    ) using (client)
group by client, total
