# standardSQL
create temporary function countcombinedvariables(payload string)
returns
    array<
        struct<
            usage string,
            freq int64 >> language js
            as
                '''
try {
  var $ = JSON.parse(payload);
  var scss = JSON.parse($['_sass']);
  if (!scss.scss) {
    return [];
  }

  return Object.entries(scss.scss.stats.variablesCombined).map(([usage, obj]) => ({usage, freq: Object.keys(obj).length}));
} catch (e) {
  return [];
}
'''
;

select
    percentile,
    client,
    usage,
    approx_quantiles(freq, 1000 ignore nulls)[offset(percentile * 10)] as freq
from
    (
        select _table_suffix as client, var.usage, var.freq
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(countcombinedvariables(payload)) as var
    ),
    unnest([10, 25, 50, 75, 90, 100]) as percentile
group by percentile, client, usage
order by percentile, client, usage
