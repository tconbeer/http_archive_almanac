CREATE TEMPORARY FUNCTION getPictureSwitching(payload STRING)
RETURNS ARRAY<STRUCT<pictureMediaSwitching BOOLEAN, pictureTypeSwitching BOOLEAN>>
LANGUAGE js AS '''
try {
  var $ = JSON.parse(payload);
  var responsiveImages = JSON.parse($._responsive_images);
  responsiveImages = responsiveImages['responsive-images'];

  return responsiveImages.filter(img => img.isInPicture).map(({pictureMediaSwitching, pictureTypeSwitching}) => ({
    pictureMediaSwitching,
    pictureTypeSwitching
  }));
} catch (e) {
  return [];
}
''';

select
    _table_suffix as client,
    countif(image.picturemediaswitching) as picture_media_switching,
    countif(image.picturetypeswitching) as picture_type_switching,
    count(0) as total_picture,
    countif(image.picturemediaswitching) / count(0) as pct_picture_media_switching,
    countif(image.picturetypeswitching) / count(0) as pct_picture_type_switching
from `httparchive.pages.2021_07_01_*`, unnest(getpictureswitching(payload)) as image
group by client
