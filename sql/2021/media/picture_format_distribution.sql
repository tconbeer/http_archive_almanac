# standardSQL
# picture formats distribution
# returns all the data we need from _media
CREATE TEMPORARY FUNCTION get_media_info(media_string STRING)
RETURNS STRUCT<
  num_picture_img INT64,
  num_picture_formats INT64,
  picture_formats ARRAY<STRING>
> LANGUAGE js AS '''
var result = {};
try {
    var media = JSON.parse(media_string);

    if (Array.isArray(media) || typeof media != 'object') return result;

    // fix "picture_formats":"[]"
    if (!Array.isArray(media.picture_formats))
    {
      media.picture_formats = JSON.parse(media.picture_formats);
    }

    // skip "picture_formats":[{}]
    if (media.picture_formats.length == 1 && Object.keys(media.picture_formats[0]).length === 0)
    {
      media.picture_formats = [];
    }

    result.picture_formats = media.picture_formats;
    result.num_picture_img = media.num_picture_img;
    result.num_picture_formats = result.picture_formats.length;

} catch (e) {}
return result;
''';

select
    client,
    safe_divide(
        countif(media_info.num_picture_formats > 0),
        countif(media_info.num_picture_img > 0)
    ) as pages_with_picture_formats_pct,
    safe_divide(
        countif(media_info.num_picture_formats = 1),
        countif(media_info.num_picture_formats > 0)
    ) as pages_with_picture_formats_1_pct,
    safe_divide(
        countif(media_info.num_picture_formats = 2),
        countif(media_info.num_picture_formats > 0)
    ) as pages_with_picture_formats_2_pct,
    safe_divide(
        countif(media_info.num_picture_formats = 3),
        countif(media_info.num_picture_formats > 0)
    ) as pages_with_picture_formats_3_pct,
    safe_divide(
        countif(media_info.num_picture_formats >= 4),
        countif(media_info.num_picture_formats > 0)
    ) as pages_with_picture_formats_4_and_more_pct,
    safe_divide(
        countif('image/webp' in unnest(media_info.picture_formats)),
        countif(media_info.num_picture_formats > 0)
    ) as pages_with_webp_pct,
    safe_divide(
        countif('image/gif' in unnest(media_info.picture_formats)),
        countif(media_info.num_picture_formats > 0)
    ) as pages_with_gif_pct,
    safe_divide(
        countif('image/jpg' in unnest(media_info.picture_formats)),
        countif(media_info.num_picture_formats > 0)
    ) as pages_with_jpg_pct,
    safe_divide(
        countif('image/png' in unnest(media_info.picture_formats)),
        countif(media_info.num_picture_formats > 0)
    ) as pages_with_png_pct,
    safe_divide(
        countif('image/avif' in unnest(media_info.picture_formats)),
        countif(media_info.num_picture_formats > 0)
    ) as pages_with_avif_pct
from
    (
        select
            _table_suffix as client,
            get_media_info(json_extract_scalar(payload, '$._media')) as media_info
        from `httparchive.pages.2021_08_01_*`
    )
group by client
order by client
