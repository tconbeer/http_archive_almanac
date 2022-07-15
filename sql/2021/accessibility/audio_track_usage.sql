# standardSQL
# Audio elements track usage
select
    client,
    count(0) as total_sites,
    countif(total_audios > 0) as total_with_audio,
    countif(total_with_track > 0) as total_with_tracks,

    sum(total_with_track) / sum(total_audios) as pct_audios_with_tracks,
    countif(total_audios > 0) / count(0) as pct_sites_with_audios,
    countif(total_with_track > 0)
    / countif(total_audios > 0) as pct_audio_sites_with_tracks
from
    (
        select
            _table_suffix as client,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'), '$.audios.total'
                ) as int64
            ) as total_audios,
            cast(
                json_extract_scalar(
                    json_extract_scalar(payload, '$._almanac'),
                    '$.audios.total_with_track'
                ) as int64
            ) as total_with_track
        from `httparchive.pages.2021_07_01_*`
    )
group by client
