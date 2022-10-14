# standardSQL
# picture using orientation
# returns all the data we need from _media
CREATE TEMPORARY FUNCTION get_media_info(media_string STRING)
RETURNS STRUCT<
  num_picture_img INT64,
  num_picture_using_orientation INT64
> LANGUAGE js AS '''
var result = {};
try {
    var media = JSON.parse(media_string);

    if (Array.isArray(media) || typeof media != 'object') return result;

    result.num_picture_img = media.num_picture_img;
    result.num_picture_using_orientation = media.num_picture_using_orientation;

} catch (e) {}
return result;
''';

select
    client,
    safe_divide(
        countif(media_info.num_picture_using_orientation > 0),
        countif(media_info.num_picture_img > 0)
    ) as pages_with_picture_orientation_pct,
    safe_divide(
        sum(media_info.num_picture_using_orientation), sum(media_info.num_picture_img)
    ) as occurences_of_picture_orientation_pct
from
    (
        select
            _table_suffix as client,
            get_media_info(json_extract_scalar(payload, '$._media')) as media_info
        from `httparchive.pages.2020_08_01_*`
    )
group by client
order by client
