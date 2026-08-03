select
    client,
    countif(num_video_nodes > 0) as pages,
    count(0) as total,
    countif(num_video_nodes > 0) / count(0) as pct
from
    (
        select
            _table_suffix as client,
            cast(
                json_value(
                    json_value(payload, '$._media'), '$.num_video_nodes'
                ) as int64
            ) as num_video_nodes
        from `httparchive.pages.2021_07_01_*`
    )
group by client
