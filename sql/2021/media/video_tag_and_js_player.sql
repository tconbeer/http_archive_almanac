# standardSQL
# get all pages with video nodes
# along with all pages with video js files
# check if video js is imported when a page has a video element or not
CREATE TEMPORARY FUNCTION get_media_info(media_string STRING)
RETURNS STRUCT<
  num_video_nodes INT64
> LANGUAGE js AS '''
var result = {};
try {
    var media = JSON.parse(media_string);

    if (Array.isArray(media) || typeof media != 'object') return result;

    result.num_video_nodes = media.num_video_nodes;

} catch (e) {}
return result;
''';

select
    client,
    countif(video_nodes) / count(0) as video_tag_pct,
    countif(player is not null) / count(0) as js_video_player_pct,
    countif(video_nodes and player is not null)
    / count(0) as both_video_tag_js_player_pct
from
    (
        select client, media_info.num_video_nodes > 0 as video_nodes, player
        from
            (
                select
                    _table_suffix as client,
                    get_media_info(
                        json_extract_scalar(payload, '$._media')
                    ) as media_info
                from `httparchive.pages.2021_08_01_*`
            )
        full outer join
            (
                select
                    client,
                    lower(
                        regexp_extract(
                            url,
                            '(?i)(hls|video|shaka|jwplayer|brightcove-player-loader|flowplayer)[(?:\\.min)]?\\.js'
                        )
                    ) as player
                from `httparchive.almanac.requests`
                where date = '2021-08-01' and type = 'script'
                group by client, page, player
            ) using (client, url)
        group by client, url, video_nodes, player
        having video_nodes or player is not null
    )
group by client
order by client
