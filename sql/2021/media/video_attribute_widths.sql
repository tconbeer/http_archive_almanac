# standardSQL
create temp function parseint(n string) returns string language js
as '''
try {
  return parseInt(n, 10);
} catch (e) {
  return null;
}
'''
;


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
    floor(safe_cast(parseint(value) as int64) / 100) * 100 as width,
    sum(cnt) as freq,
    sum(sum(cnt)) over (partition by client) as total,
    sum(cnt) / sum(sum(cnt)) over (partition by client) as pct
from video_attributes
where attribute = 'width'
group by client, width
having width >= 0
order by width
