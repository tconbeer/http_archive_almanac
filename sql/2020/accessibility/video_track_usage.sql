# standardSQL
# Video elements track usage
select
    client,
    count(0) as total_sites,
    countif(total_videos > 0) as total_with_video,
    countif(total_tracks > 0) as total_with_tracks,

    countif(total_videos > 0) / count(0) as pct_sites_with_videos,
    countif(total_tracks > 0) / countif(total_videos > 0) as pct_video_sites_with_tracks
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'), '$.videos.total'
                ) as int64
            ) as total_videos,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'), '$.videos.tracks.total'
                ) as int64
            ) as total_tracks
        from `httparchive.pages.2020_08_01_*`
    )
group by client
