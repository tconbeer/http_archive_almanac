# standardSQL
# 14_13c: Distribution of image dimensions
CREATE TEMPORARY FUNCTION getImageDimensions(payload STRING)
RETURNS ARRAY<STRUCT<height INT64, width INT64>> LANGUAGE js AS '''
try {
  var $ = JSON.parse(payload);
  var images = JSON.parse($._Images);
  return images.map(i => ({height: i.naturalHeight, width: i.naturalWidth}));
} catch (e) {
  return [];
}
''';

select
    percentile,
    _table_suffix as client,
    approx_quantiles(image.width, 1000)[offset(percentile * 10)] as image_width,
    approx_quantiles(image.height, 1000)[offset(percentile * 10)] as image_height
from `httparchive.pages.2019_07_01_*`
join
    `httparchive.technologies.2019_07_01_*` using (_table_suffix, url),
    unnest(getimagedimensions(payload)) as image,
    unnest([10, 25, 50, 75, 90]) as percentile
where category = 'CMS'
group by percentile, client
order by percentile, client
