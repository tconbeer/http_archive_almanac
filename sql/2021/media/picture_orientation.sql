# standardSQL
# picture using orientation
create temporary function get_media_info(media_string string)
returns struct<num_picture_img int64, num_picture_using_orientation int64>
language js
as '''
var result = {};
try {
    var media = JSON.parse(media_string);

    if (Array.isArray(media) || typeof media != 'object') return result;

    result.num_picture_img = media.num_picture_img;
    result.num_picture_using_orientation = media.num_picture_using_orientation;

} catch (e) {}
return result;
'''
;

select
    client,
    countif(media_info.num_picture_using_orientation > 0) as picture_orientation_pages,
    countif(media_info.num_picture_img > 0) as total_picture_pages,
    safe_divide(
        countif(media_info.num_picture_using_orientation > 0),
        countif(media_info.num_picture_img > 0)
    ) as pct_picture_orientation_pages,
    sum(media_info.num_picture_using_orientation) as picture_orientation_images,
    sum(media_info.num_picture_img) as total_picture_images,
    safe_divide(
        sum(media_info.num_picture_using_orientation), sum(media_info.num_picture_img)
    ) as pct_picture_orientation_images
from
    (
        select
            _table_suffix as client,
            get_media_info(json_extract_scalar(payload, '$._media')) as media_info
        from `httparchive.pages.2021_07_01_*`
    )
group by client
order by client
