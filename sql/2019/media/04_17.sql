# standardSQL
# 04_17: Video player size
select
    percentile,
    client,
    player,
    sum(count(0)) over (partition by client, player) as requests,
    round(approx_quantiles(respsize, 1000)[offset(percentile * 10)] / 1024, 2) as kbytes
from
    (
        select
            client,
            respsize,
            lower(
                regexp_extract(
                    url,
                    '(?i)(hls|video|shaka|jwplayer|brightcove-player-loader|flowplayer)[(?:\\.min)]?\\.js'
                )
            ) as player
        from `httparchive.almanac.requests`
        where date = '2019-07-01' and type = 'script'
    ),
    unnest([10, 25, 50, 75, 90]) as percentile
where player is not null
group by percentile, client, player
order by percentile, client, kbytes desc
