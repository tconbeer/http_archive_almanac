# standardSQL
create temporary function hasgridtemplateareas(css string)
returns boolean
language js
options(library = "gs://httparchive/lib/css-utils.js") as '''
try {
  function compute(ast) {
    let ret = {};

    walkDeclarations(ast, ({property, value}) => {
      for (let area of value.matchAll(/(['"])(?<names>[-\\w\\s.]+?)\\1/g)) {
        let names = area.groups.names.split(/\\s+/);

        for (let name of names) {
          incrementByKey(ret, name);
        }
      }
    }, {
      properties: /^grid(-template(-areas)?)?$/
    });

    return sortObject(ret);
  }

  const ast = JSON.parse(css);
  return Object.keys(compute(ast)).length > 0;
} catch (e) {
  return false;
}
'''
;

select
    client,
    countif(grid_template_areas) as pages_with_grid_template_areas,
    # TODO: Update denominator to number of pages using `grid`.
    total,
    countif(grid_template_areas) / total as pct
from
    (
        select
            client, page, countif(hasgridtemplateareas(css)) > 0 as grid_template_areas
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
