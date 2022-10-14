# standardSQL
# picture using min resolution
# returns all the data we need from _media
CREATE TEMPORARY FUNCTION get_media_info(media_string STRING)
RETURNS STRUCT<
  num_picture_using_min_resolution INT64,
  num_picture_img INT64
> LANGUAGE js AS '''
var result = {};
try {
    var media = JSON.parse(media_string);

    if (Array.isArray(media) || typeof media != 'object') return result;

    result.num_picture_using_min_resolution = media.num_picture_using_min_resolution;
    result.num_picture_img = media.num_picture_img;

} catch (e) {}
return result;
''';

select
    client,
    countif(
        media_info.num_picture_using_min_resolution > 0
    ) as picture_min_resolution_pages,
    countif(media_info.num_picture_img > 0) as total_picture_pages,
    safe_divide(
        countif(media_info.num_picture_using_min_resolution > 0),
        countif(media_info.num_picture_img > 0)
    ) as pct_picture_min_resolution_pages,
    sum(media_info.num_picture_using_min_resolution) as picture_min_resolution_images,
    sum(media_info.num_picture_img) as total_picture_images,
    safe_divide(
        sum(media_info.num_picture_using_min_resolution),
        sum(media_info.num_picture_img)
    ) as pct_picture_min_resolution_images
from
    (
        select
            _table_suffix as client,
            get_media_info(json_extract_scalar(payload, '$._media')) as media_info
        from `httparchive.pages.2021_07_01_*`
    )
group by client
order by client
