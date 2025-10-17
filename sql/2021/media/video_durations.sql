# standardSQL
with
    videonotes as (
        select
            client,
            pageurl,
            cast(durations as float64) as durations,
            case
                when cast(durations as float64) <= 1
                then 'under1'
                when
                    (cast(durations as float64) > 1 and cast(durations as float64) <= 5)
                then 'under5'
                when
                    (
                        cast(durations as float64) > 5
                        and cast(durations as float64) <= 10
                    )
                then 'under10'
                when
                    (
                        cast(durations as float64) > 10
                        and cast(durations as float64) <= 20
                    )
                then 'under20'
                when
                    (
                        cast(durations as float64) > 20
                        and cast(durations as float64) <= 30
                    )
                then 'under30'
                when
                    (
                        cast(durations as float64) > 30
                        and cast(durations as float64) <= 45
                    )
                then 'under45'
                when
                    (
                        cast(durations as float64) > 45
                        and cast(durations as float64) <= 60
                    )
                then 'under60'
                when
                    (
                        cast(durations as float64) > 60
                        and cast(durations as float64) <= 90
                    )
                then 'under90'
                when
                    (
                        cast(durations as float64) > 90
                        and cast(durations as float64) <= 120
                    )
                then 'under120'
                when
                    (
                        cast(durations as float64) > 120
                        and cast(durations as float64) <= 180
                    )
                then 'under180'
                when
                    (
                        cast(durations as float64) > 180
                        and cast(durations as float64) <= 300
                    )
                then 'under300'
                when
                    (
                        cast(durations as float64) > 300
                        and cast(durations as float64) <= 600
                    )
                then 'under600'
                else 'over600'
            end as duration_bucket
        from
            (
                select
                    _table_suffix as client,
                    url as pageurl,
                    json_value(payload, '$._media') as media,
                    cast(
                        json_value(
                            json_value(payload, '$._media'), '$.num_video_nodes'
                        ) as int64
                    ) as num_video_nodes,
                    (
                        json_query_array(
                            json_value(payload, '$._media'), '$.video_durations'
                        )
                    ) as video_duration,
                    (
                        json_query(
                            json_value(payload, '$._media'), '$.video_display_style'
                        )
                    ) as video_display_style,
                    (
                        json_query_array(
                            json_value(payload, '$._media'),
                            '$.video_attributes_values_counts'
                        )
                    ) as video_attributes_values_counts,
                    (
                        json_query_array(
                            json_value(payload, '$._media'),
                            '$.video_source_format_count'
                        )
                    ) as video_source_format_count,
                    (
                        json_query_array(
                            json_value(payload, '$._media'),
                            '$.video_source_format_type'
                        )
                    ) as video_source_format_type
                from `httparchive.pages.2021_07_01_*`
            )
        cross join unnest(video_duration) as durations
        where num_video_nodes > 0 and durations != 'null'
        order by durations desc
    )

select
    client,
    duration_bucket,
    count(duration_bucket) as freq,
    count(duration_bucket) / sum(count(0)) over (partition by client) as pct
from videonotes
group by client, duration_bucket
order by freq desc
