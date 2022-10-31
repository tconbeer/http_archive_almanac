# standardSQL
# 13_06c: Distribution of image dimensions
# # $4.11 run
create temporary function getimagedimensions(payload string)
returns
    array< struct<height int64, width int64 >> language js as '''
try {
  var $ = JSON.parse(payload);
  var images = JSON.parse($._Images);
  return images.map(i => ({height: i.naturalHeight, width: i.naturalWidth}));
} catch (e) {
  return [];
}
'''
;

select
    percentile,
    _table_suffix as client,
    approx_quantiles(image.width, 1000)[offset(percentile * 10)] as image_width,
    approx_quantiles(image.height, 1000)[offset(percentile * 10)] as image_height
from `httparchive.pages.2021_07_01_*`
join
    `httparchive.technologies.2021_07_01_*` using (_table_suffix, url),
    unnest(getimagedimensions(payload)) as image,
    unnest([10, 25, 50, 75, 90])
where
    category = 'Ecommerce'
    and (app != 'Cart Functionality' and app != 'Google Analytics Enhanced eCommerce')
group by percentile, client
order by percentile, client
