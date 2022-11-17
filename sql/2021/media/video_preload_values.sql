# standardSQL
# preload attribute values
select
    date,
    client,
    if(preload_value = '', '(empty)', preload_value) as preload_value,
    count(0) as preload_value_count,
    safe_divide(
        count(0), sum(count(0)) over (partition by date, client)
    ) as preload_value_pct
from
    (
        select
            '2021-07-01' as date,
            _table_suffix as client,
            lower(
                ifnull(
                    json_extract_scalar(video_nodes, '$.preload'), '(preload not used)'
                )
            ) as preload_value
        from
            `httparchive.pages.2021_07_01_*`,
            unnest(
                json_extract_array(
                    json_extract_scalar(payload, '$._almanac'), '$.videos.nodes'
                )
            ) as video_nodes
        union all
        select
            '2020-08-01' as date,
            _table_suffix as client,
            lower(
                ifnull(
                    json_extract_scalar(video_nodes, '$.preload'), '(preload not used)'
                )
            ) as preload_value
        from
            `httparchive.pages.2020_08_01_*`,
            unnest(
                json_extract_array(
                    json_extract_scalar(payload, '$._almanac'), '$.videos.nodes'
                )
            ) as video_nodes
    )
group by date, client, preload_value
qualify preload_value_count > 10
order by date, client, preload_value_count desc
;
