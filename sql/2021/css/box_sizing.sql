# standardSQL
# 1. Distribution of the number of occurrences of box-sizing:border-box per page.
# 2. Percent of pages with that style.
create temporary function countborderboxdeclarations(css string)
returns numeric
language js
options(library = "gs://httparchive/lib/css-utils.js")
as '''
try {
  const ast = JSON.parse(css);
  return countDeclarations(ast.stylesheet.rules, {properties: /^(-(o|moz|webkit|ms)-)?box-sizing$/, values: 'border-box'});
} catch (e) {
  return null;
}
'''
;

select
    percentile,
    client,
    count(distinct if(declarations > 0, page, null)) as pages,
    count(distinct page) as total,
    count(distinct if(declarations > 0, page, null)) / count(
        distinct page
    ) as pct_pages,
    approx_quantiles(declarations, 1000 ignore nulls) [
        offset (percentile * 10)
    ] as declarations_per_page
from
    (
        select client, page, countborderboxdeclarations(css) as declarations
        from `httparchive.almanac.parsed_css`
        where date = '2021-07-01'
    ),
    unnest( [10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
