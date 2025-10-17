# standardSQL
create temporary function getdeclarationcounts(css string)
returns struct<total numeric, unique numeric>
language js
options (library = "gs://httparchive/lib/css-utils.js")
as '''
try {
    function compute() {
        let ret = {total: 0};
        let unique = new Set();

        walkDeclarations(ast, ({property, value}) => {
          if (!property.startsWith("--")) { // Custom props are case sensitive
              property = property.toLowerCase();
          }

          ret.total++;
          unique.add(`${property}: ${value}`);
        });

        ret.unique = unique.size;

        return ret;
    }

  const ast = JSON.parse(css);
  return compute(ast);
} catch (e) {
  return null;
}
'''
;

select
    percentile,
    client,
    approx_quantiles(total, 1000 ignore nulls)[offset(percentile * 10)] as total,
    approx_quantiles(unique, 1000 ignore nulls)[offset(percentile * 10)] as unique,
    approx_quantiles(safe_divide(unique, total), 1000 ignore nulls)[
        offset(percentile * 10)
    ] as unique_ratio
from
    (
        select client, sum(info.total) as total, sum(info.unique) as unique
        from
            (
                select client, page, getdeclarationcounts(css) as info
                from `httparchive.almanac.parsed_css`
                where date = '2020-08-01'
            )
        group by client, page
    ),
    unnest([10, 25, 50, 75, 90, 95, 100]) as percentile
group by percentile, client
order by percentile, client
