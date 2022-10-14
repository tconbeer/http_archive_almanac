CREATE TEMPORARY FUNCTION getSizesAccuracy(payload STRING)
RETURNS ARRAY<STRUCT<sizesAbsoluteError INT64, sizesRelativeError FLOAT64>>
LANGUAGE js AS '''
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
''';

select
    percentile,
    client,
    approx_quantiles(image.sizesabsoluteerror, 1000)[
        offset(percentile * 10)
    ] as sizesabsoluteerror,
    approx_quantiles(image.sizesrelativeerror, 1000)[
        offset(percentile * 10)
    ] as sizesrelativeerror
from
    (
        select _table_suffix as client, image
        from
            `httparchive.pages.2021_07_01_*`, unnest(getsizesaccuracy(payload)) as image
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
group by percentile, client
order by percentile, client
