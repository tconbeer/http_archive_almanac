# standardSQL
create temporary function getimportantproperties(css string)
returns struct < total int64,
important int64 > language js
options(library = "gs://httparchive/lib/css-utils.js") as '''
try {
  var ast = JSON.parse(css);
  let ret = {
    total: 0,
    important: 0,
    properties: {}
  };

  walkDeclarations(ast, ({property, important}) => {
    ret.total++;

    if (important) {
      ret.important++;
      incrementByKey(ret.properties, property);
    }
  });

  ret.properties = sortObject(ret.properties);

  return ret;
} catch (e) {
  return [];
}
'''
;

select
    percentile,
    client,
    countif(pct_important = 100) as all_important_pages,
    approx_quantiles(pct_important, 1000)[
        offset(percentile * 10)
    ] as pct_important_props
from
    (
        select
            client,
            page,
            safe_divide(
                sum(properties.important), sum(properties.total)
            ) as pct_important
        from
            (
                select client, page, getimportantproperties(css) as properties
                from `httparchive.almanac.parsed_css`
                where date = '2020-08-01'
            )
        group by client, page
    ),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
