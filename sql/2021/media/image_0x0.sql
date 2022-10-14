CREATE TEMPORARY FUNCTION getPixelInfo(responsiveImagesJsonString STRING)
RETURNS ARRAY<STRUCT<imgURL STRING, approximateResourceWidth INT64, approximateResourceHeight INT64, byteSize INT64, isPixel BOOL, isDataURL BOOL>>
LANGUAGE js AS '''
const parsed = JSON.parse(responsiveImagesJsonString);
if (parsed && parsed.map) {
  const dataRegEx = new RegExp('^data');
  return parsed.map(d => ({
    isPixel: d.approximateResourceWidth == 0 && d.approximateResourceHeight == 0,
    isDataURL: dataRegEx.test(d.url)
  }));
}
''';

with
    imgs as (
        select _table_suffix as client, ispixel, isdataurl
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(
                getpixelinfo(
                    json_query(
                        json_value(payload, '$._responsive_images'),
                        '$.responsive-images'
                    )
                )
            )
    ),

    counts as (
        select
            client,
            count(0) as total_imgs,
            countif(ispixel) as zero_pixel_imgs,
            countif(ispixel and isdataurl) as zero_pixel_data_urls
        from imgs
        group by client
    )

select
    client,
    total_imgs,
    zero_pixel_imgs,
    zero_pixel_data_urls,
    safe_divide(zero_pixel_imgs, total_imgs) as pct_zero_pixel_imgs,
    safe_divide(zero_pixel_data_urls, total_imgs) as pct_zero_pixel_data_urls
from counts
