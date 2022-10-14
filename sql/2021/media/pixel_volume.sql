# standardSQL
# pixel volume
CREATE TEMPORARY FUNCTION getCssPixels(payload STRING)
RETURNS INT64 LANGUAGE js AS '''
try {
  let data = JSON.parse(payload);
  return data.reduce((a, c) => a + (c.width||0)*(c.height||0), 0) || 0;
}
catch (e) {}
return null;
''';

CREATE TEMPORARY FUNCTION getNaturalPixels(payload STRING)
RETURNS INT64 LANGUAGE js AS '''
try {
  let data = JSON.parse(payload);
  return data.reduce((a, c) => a + (c.naturalWidth||0)*(c.naturalHeight||0), 0) || 0;
}
catch (e) {}
return null;
''';

select
    percentile,
    client,
    any_value(viewport_height) as viewport_height,
    any_value(viewport_width) as viewport_width,
    any_value(dpr) as dpr,
    any_value(viewport_height) * any_value(viewport_width) as display_px,
    approx_quantiles(css_pixels, 1000)[offset(percentile * 10)] as css_pixels,
    approx_quantiles(natural_pixels, 1000)[offset(percentile * 10)] as natural_pixels,
    approx_quantiles(natural_pixels, 1000)[offset(percentile * 10)]
    / (any_value(viewport_height) * any_value(viewport_width)) as pct
from
    (
        select
            _table_suffix as client,
            url as page,
            getcsspixels(json_extract_scalar(payload, '$._Images')) as css_pixels,
            getnaturalpixels(
                json_extract_scalar(payload, '$._Images')
            ) as natural_pixels,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._Dpi'), '$.dppx'
                ) as float64
            ) as dpr,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._Resolution'), '$.absolute.height'
                ) as float64
            ) as viewport_height,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._Resolution'), '$.absolute.width'
                ) as float64
            ) as viewport_width
        from `httparchive.pages.2021_07_01_*`
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
# it appears the _Images array is populated only from <img> tag requests and not CSS
# or favicon
# likewise the bigImageCount and smallImageCount only track images > 100,000 and <
# 10,000 respectively.
# Meaning images between 10KB and 100KB won't show up in the count
# https://github.com/WPO-Foundation/webpagetest/blob/master/www/breakdown.inc#L95
where csspixels > 0 and naturalpixels > 0
group by percentile, client
order by percentile, client
