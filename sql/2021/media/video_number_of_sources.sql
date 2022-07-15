# standardSQL
with
    videonotes as (
        select
            client,
            pageurl,
            num_video_nodes,
            video_source_format_count,
            source_count,
            video_source_format_type
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
                        json_query(json_value(payload, '$._media'), '$.video_durations')
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
                        json_query(
                            json_value(payload, '$._media'),
                            '$.video_source_format_type'
                        )
                    ) as video_source_format_type
                from `httparchive.pages.2021_07_01_*`
            )
        cross join unnest(video_source_format_count) as source_count

    ),

    total_videos as (
        select
            client,
            count(distinct pageurl) as urls,
            sum(num_video_nodes) as total_video_nodes
        from videonotes
        group by client
    )

select
    client,
    cast(source_count as int64) as source_counter,
    count(cast(source_count as int64)) as numberofoccurances,
    count(cast(source_count as int64))
    / total_video_nodes as pct_numberofoccurances_per_video
from videonotes
join total_videos using(client)
where num_video_nodes > 0
group by client, source_count, total_video_nodes
order by numberofoccurances desc, source_counter desc
