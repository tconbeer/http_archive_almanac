create temporary function getpixelinfo(responsiveimagesjsonstring string)
returns array < struct < imgurl string,
approximateresourcewidth int64,
approximateresourceheight int64,
bytesize int64,
ispixel bool,
isdataurl bool
>> language js as '''
const parsed = JSON.parse(responsiveImagesJsonString);
if (parsed && parsed.map) {
  const dataRegEx = new RegExp('^data');
  return parsed.map(d => ({
    isPixel: d.approximateResourceWidth == 1 && d.approximateResourceHeight == 1,
    isDataURL: dataRegEx.test(d.url)
  }));
}
'''
;

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
            countif(ispixel) as one_pixel_imgs,
            countif(ispixel and isdataurl) as one_pixel_data_urls
        from imgs
        group by client
    )

select
    client,
    total_imgs,
    one_pixel_imgs,
    one_pixel_data_urls,
    safe_divide(one_pixel_imgs, total_imgs) as pct_one_pixel_imgs,
    safe_divide(one_pixel_data_urls, total_imgs) as pct_one_pixel_data_urls
from counts
