create temporary function getresourcehints(payload string)
returns struct < preload int64,
prefetch int64,
preconnect int64,
prerender int64,
`dns-prefetch` int64,
`modulepreload` int64
>
language js
as '''
var hints = ['preload', 'prefetch', 'preconnect', 'prerender', 'dns-prefetch', 'modulepreload'];
try {
  var $ = JSON.parse(payload);
  var almanac = JSON.parse($._almanac);
  return hints.reduce((results, hint) => {
    // Null values are omitted from BigQuery aggregations.
    // This means only pages with at least one hint are considered.
    results[hint] = almanac['link-nodes'].nodes.filter(link => link.rel.toLowerCase() == hint).length || 0;
    return results;
  }, {});
} catch (e) {
  return hints.reduce((results, hint) => {
    results[hint] = 0;
    return results;
  }, {});
}
'''
;

create temporary function getgoodcwv(payload string)
returns struct < cumulative_layout_shift boolean,
first_contentful_paint boolean,
first_input_delay boolean,
largest_contentful_paint boolean
>
language js
as '''
try {
  var $ = JSON.parse(payload);
  var crux = $._CrUX;

  if (crux) {
    return Object.keys(crux.metrics).reduce((acc, n) => ({
      ...acc,
      [n]: crux.metrics[n].histogram[0].density > 0.75
    }), {})
  }

  return null;
} catch (e) {
  return null;
}
'''
;

select
    device,

    least(hints.preload, 30) as preload,

    count(0) as freq,
    sum(count(0)) over (partition by device) as total,

    countif(crux.largest_contentful_paint) as lcp_good,
    countif(crux.largest_contentful_paint is not null) as any_lcp,
    countif(crux.largest_contentful_paint) / countif(
        crux.largest_contentful_paint is not null
    ) as pct_lcp_good,

    countif(crux.first_input_delay) as fid_good,
    countif(crux.first_input_delay is not null) as any_fid,
    countif(crux.first_input_delay) / countif(
        crux.first_input_delay is not null
    ) as pct_fid_good,

    countif(crux.cumulative_layout_shift) as cls_good,
    countif(crux.cumulative_layout_shift is not null) as any_cls,
    countif(crux.cumulative_layout_shift) / countif(
        crux.cumulative_layout_shift is not null
    ) as pct_cls_good,

    countif(crux.first_contentful_paint) as fcp_good,
    countif(crux.first_contentful_paint is not null) as any_fcp,
    countif(crux.first_contentful_paint) / countif(
        crux.first_contentful_paint is not null
    ) as pct_fcp_good,

    countif(
        crux.largest_contentful_paint
        and crux.first_input_delay is not false
        and crux.cumulative_layout_shift
    ) as cwv_good,
    countif(
        crux.largest_contentful_paint is not null
        and crux.cumulative_layout_shift is not null
    ) as eligible_cwv,
    countif(
        crux.largest_contentful_paint
        and crux.first_input_delay is not false
        and crux.cumulative_layout_shift
    ) / countif(
        crux.largest_contentful_paint is not null
        and crux.cumulative_layout_shift is not null
    ) as pct_cwv_good
from
    (
        select
            _table_suffix as device,
            getresourcehints(payload) as hints,
            getgoodcwv(payload) as crux
        from `httparchive.pages.2021_07_01_*`
    )
where crux is not null
group by device, preload
order by device, preload
