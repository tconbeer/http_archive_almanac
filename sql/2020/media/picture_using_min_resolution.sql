# standardSQL
# picture using min resolution
# returns all the data we need from _media
create temporary function get_media_info(media_string string)
returns struct < num_picture_using_min_resolution int64,
num_picture_img int64
> language js as '''
var result = {};
try {
    var media = JSON.parse(media_string);

    if (Array.isArray(media) || typeof media != 'object') return result;

    result.num_picture_using_min_resolution = media.num_picture_using_min_resolution;
    result.num_picture_img = media.num_picture_img;

} catch (e) {}
return result;
'''
;

select
    client,
    safe_divide(
        countif(media_info.num_picture_img > 0), count(0)
    ) as pages_with_picture_pct,
    safe_divide(
        countif(media_info.num_picture_using_min_resolution > 0),
        countif(media_info.num_picture_img > 0)
    ) as pages_with_picture_min_resolution_pct,
    safe_divide(
        sum(media_info.num_picture_using_min_resolution),
        sum(media_info.num_picture_img)
    ) as occurences_of_picture_min_resolution_pct
from
    (
        select
            _table_suffix as client,
            get_media_info(json_extract_scalar(payload, '$._media')) as media_info
        from `httparchive.pages.2020_08_01_*`
    )
group by client
order by client
