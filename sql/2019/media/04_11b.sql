# standardSQL
# 04_11b: pixel volume
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
    client,
    count(0) as count,
    any_value(viewportheight) as viewportheight,
    any_value(viewportwidth) as viewportwidth,
    any_value(dpr) as dpr,
    any_value(viewportheight) * any_value(viewportwidth) as displaypx,
    approx_quantiles(csspixels, 1000)[offset(100)] as csspixels_p10,
    approx_quantiles(csspixels, 1000)[offset(250)] as csspixels_p25,
    approx_quantiles(csspixels, 1000)[offset(500)] as csspixels_p50,
    approx_quantiles(csspixels, 1000)[offset(750)] as csspixels_p75,
    approx_quantiles(csspixels, 1000)[offset(900)] as csspixels_p90,
    approx_quantiles(naturalpixels, 1000)[offset(100)] as naturalpixels_p10,
    approx_quantiles(naturalpixels, 1000)[offset(250)] as naturalpixels_p25,
    approx_quantiles(naturalpixels, 1000)[offset(500)] as naturalpixels_p50,
    approx_quantiles(naturalpixels, 1000)[offset(750)] as naturalpixels_p75,
    approx_quantiles(naturalpixels, 1000)[offset(900)] as naturalpixels_p90,
    round(
        approx_quantiles(naturalpixels, 1000)[offset(100)]
        / (any_value(viewportheight) * any_value(viewportwidth)),
        2
    ) as pct_p10,
    round(
        approx_quantiles(naturalpixels, 1000)[offset(250)]
        / (any_value(viewportheight) * any_value(viewportwidth)),
        2
    ) as pct_p25,
    round(
        approx_quantiles(naturalpixels, 1000)[offset(500)]
        / (any_value(viewportheight) * any_value(viewportwidth)),
        2
    ) as pct_p50,
    round(
        approx_quantiles(naturalpixels, 1000)[offset(750)]
        / (any_value(viewportheight) * any_value(viewportwidth)),
        2
    ) as pct_p75,
    round(
        approx_quantiles(naturalpixels, 1000)[offset(900)]
        / (any_value(viewportheight) * any_value(viewportwidth)),
        2
    ) as pct_p90
from
    (
        select
            _table_suffix as client,
            url as page,
            getcsspixels(json_extract_scalar(payload, '$._Images')) as csspixels,
            getnaturalpixels(
                json_extract_scalar(payload, '$._Images')
            ) as naturalpixels,
            cast(
                json_extract_scalar(payload, '$._smallImageCount') as int64
            ) as smallimagecount,
            cast(
                json_extract_scalar(payload, '$._bigImageCount') as int64
            ) as bigimagecount,
            cast(json_extract_scalar(payload, '$._image_total') as int64) as imagebytes,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._Dpi'), '$.dppx'
                ) as float64
            ) as dpr,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._Resolution'), '$.absolute.height'
                ) as int64
            ) as viewportheight,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._Resolution'), '$.absolute.width'
                ) as int64
            ) as viewportwidth
        from `httparchive.pages.2019_07_01_*`
    -- LIMIT 1000
    )
# it appears the _Images array is populated only from <img> tag requests and not CSS
# or favicon
# likewise the bigImageCount and smallImageCount only track images > 100,000 and <
# 10,000 respectively.
# Meaning images between 10KB and 100KB won't show up in the count
# https://github.com/WPO-Foundation/webpagetest/blob/master/www/breakdown.inc#L95
where csspixels > 0 and naturalpixels > 0 and (smallimagecount > 0 or bigimagecount > 0)
group by client
order by client desc
