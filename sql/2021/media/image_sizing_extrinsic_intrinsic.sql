create temporary function getimagesizing(payload string)
returns
    array< struct<property string, value string >> language js as '''
try {
  var $ = JSON.parse(payload);
  var responsiveImages = JSON.parse($._responsive_images);
  responsiveImages = responsiveImages['responsive-images'];

  return responsiveImages.flatMap(({intrinsicOrExtrinsicSizing}) => ([
    {property: 'width', value: intrinsicOrExtrinsicSizing.width},
    {property: 'height', value: intrinsicOrExtrinsicSizing.height}
  ]));
} catch (e) {
  return [];
}
'''
;

select
    _table_suffix as client,
    image.property,
    image.value,
    count(0) as freq,
    sum(count(0)) over (partition by _table_suffix, image.property) as total,
    count(0) / sum(count(0)) over (partition by _table_suffix, image.property) as pct
from `httparchive.pages.2021_07_01_*`, unnest(getimagesizing(payload)) as image
group by client, property, value
order by pct desc
