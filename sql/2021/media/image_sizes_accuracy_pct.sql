create temporary function getsizesaccuracy(payload string)
returns
    array<
        struct<
            sizesabsoluteerror int64, sizesrelativeerror float64 >> language js as '''
try {
  var $ = JSON.parse(payload);
  var responsiveImages = JSON.parse($._responsive_images);
  responsiveImages = responsiveImages['responsive-images'];

  return responsiveImages.map(({sizesAbsoluteError, sizesRelativeError}) => ({
    sizesAbsoluteError,
    sizesRelativeError
  }));
} catch (e) {
  return [];
}
'''
;

select
    _table_suffix as client,
    countif(image.sizesrelativeerror < 0.05) as small_relative_error,
    count(0) as total,
    countif(image.sizesrelativeerror < 0.05) / count(0) as pct
from `httparchive.pages.2021_07_01_*`, unnest(getsizesaccuracy(payload)) as image
group by client
