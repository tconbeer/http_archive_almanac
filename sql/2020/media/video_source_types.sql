# standardSQL
# get video source types
select
    client,
    lower(video_type) as video_type,
    count(0) as video_type_count,
    safe_divide(count(0), sum(count(0)) over (partition by client)) as video_type_pct
from
    `httparchive.almanac.summary_response_bodies`,
    unnest(regexp_extract_all(body, '(?i)(<video.*?</video>)')) as video,
    unnest(
        regexp_extract_all(video, r'(?i)type\s*=\s*["\'](video/[^\'";?]*)')
    ) as video_type
where date = '2020-08-01' and firsthtml
group by client, video_type
order by client, video_type_count desc
