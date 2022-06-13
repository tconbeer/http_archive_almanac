# standardSQL
# video autoplay/muted
# returns all the data we need from _media
create temporary function get_media_info(media_string string)
returns struct < num_video_nodes int64,
video_nodes_attributes array
< string
>
> language js
as '''
var result = {};
try {
    var media = JSON.parse(media_string);

    if (Array.isArray(media) || typeof media != 'object') return result;

    // fix "video_nodes_attributes":"[]"
    if (!Array.isArray(media.video_nodes_attributes))
    {
      media.video_nodes_attributes = JSON.parse(media.video_nodes_attributes);
    }

    // skip "video_nodes_attributes":[{}]
    if (media.video_nodes_attributes.length == 1 && Object.keys(media.video_nodes_attributes[0]).length === 0)
    {
      media.video_nodes_attributes = [];
    }

    result.video_nodes_attributes = media.video_nodes_attributes;
    result.num_video_nodes = media.num_video_nodes;

} catch (e) {}
return result;
'''
;

select
    client,
    safe_divide(
        countif(media_info.num_video_nodes > 0), count(0)
    ) as pages_with_video_nodes_pct,
    safe_divide(
        countif('autoplay' in unnest(media_info.video_nodes_attributes)),
        countif(media_info.num_video_nodes > 0)
    ) as pages_with_video_autoplay_pct,
    safe_divide(
        countif('muted' in unnest(media_info.video_nodes_attributes)),
        countif(media_info.num_video_nodes > 0)
    ) as pages_with_video_muted_pct,
    safe_divide(
        countif(
            'autoplay' in unnest(media_info.video_nodes_attributes) and
            'muted' in unnest(media_info.video_nodes_attributes)
        ),
        countif(media_info.num_video_nodes > 0)
    ) as pages_with_video_autoplay_muted_pct
from
    (
        select
            _table_suffix as client,
            get_media_info(json_extract_scalar(payload, '$._media')) as media_info
        from `httparchive.pages.2020_08_01_*`
    )
group by client
order by client
