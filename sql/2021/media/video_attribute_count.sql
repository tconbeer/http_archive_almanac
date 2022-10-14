# standardSQL
with
    videonotes as (

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
                json_query_array(json_value(payload, '$._media'), '$.video_durations')
            ) as video_duration,
            (
                json_query_array(
                    json_value(payload, '$._media'), '$.video_display_style'
                )
            ) as video_display_style,
            array_to_string(
                json_query_array(
                    json_value(payload, '$._media'), '$.video_attributes_values_counts'
                ),
                ' '
            ) as video_attributes_values_counts,
            (
                json_query_array(
                    json_value(payload, '$._media'), '$.video_source_format_count'
                )
            ) as video_source_format_count,
            (
                json_query_array(
                    json_value(payload, '$._media'), '$.video_source_format_type'
                )
            ) as video_source_format_type
        from `httparchive.pages.2021_07_01_*`
    ),

    total_videos as (
        select
            client,
            count(distinct pageurl) as urls,
            sum(num_video_nodes) as num_video_nodes
        from videonotes
        group by client
    ),

    video_attributes as (
        select
            client,
            pageurl,
            json_value(video_attributes_values_counts, '$.attribute') as attribute,
            json_value(video_attributes_values_counts, '$.value') as value,
            cast(json_value(video_attributes_values_counts, '$.count') as int64) as cnt,
            video_attributes_values_counts
        from videonotes
        where num_video_nodes > 0
    )

select
    client,
    attribute,
    value,
    sum(cnt) as freq,
    sum(cnt) / sum(sum(cnt)) over (partition by client, attribute) as pct_attribute,
    sum(cnt) / num_video_nodes as pct_videos
from video_attributes
join total_videos using (client)
group by client, attribute, value, num_video_nodes
qualify freq > 100
order by freq desc, attribute asc
