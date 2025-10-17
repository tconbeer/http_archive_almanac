# standardSQL
# Cumulative V8 main thread time
create temporary function totalmainthreadtime(payload string)
returns float64
language js
as '''
try {
  var $ = JSON.parse(payload);
  return Object.values($._v8Stats.main_thread).reduce((sum, i) => sum + i, 0);
} catch (e) {
  return null;
}
'''
;

select
    percentile,
    client,
    app as js_framework,
    count(distinct page) as pages,
    approx_quantiles(v8_time, 1000)[offset(percentile * 10)] as v8_time
from
    (
        select
            _table_suffix as client,
            url as page,
            totalmainthreadtime(payload) as v8_time
        from `httparchive.pages.2020_08_01_*`
    )
join
    (
        select distinct _table_suffix as client, url as page, app
        from `httparchive.technologies.2020_08_01_*`
        where category = 'JavaScript frameworks'
    ) using (client, page),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client, js_framework
order by percentile, client, pages desc
