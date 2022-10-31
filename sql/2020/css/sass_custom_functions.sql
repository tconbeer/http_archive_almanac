# standardSQL
create temporary function getcustomfunctioncount(payload string)
returns int64
language js
as '''
try {
  var $ = JSON.parse(payload);
  var scss = JSON.parse($['_sass']);
  if (!scss.scss) {
    return null;
  }

  return Object.keys(scss.scss.stats.functions).length;
} catch (e) {
  return null;
}
'''
;

select
    percentile,
    client,
    approx_quantiles(fn, 1000 ignore nulls)[
        offset(percentile * 10)
    ] as sass_custom_functions
from
    (
        select
            _table_suffix as client,
            url as page,
            sum(getcustomfunctioncount(payload)) as fn
        from `httparchive.pages.2020_08_01_*`
        group by client, page
    ),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client
order by percentile, client
