# standardSQL
# 04_19: Video player attributes
# Warning: Parsing HTML with regular expressions is a bad idea. This should be a
# custom metric.
select
    client,
    lower(attr) as attr,
    count(0) as freq,
    count(distinct page) as pages,
    sum(count(0)) over (partition by client) as total_attr,
    total as total_pages,
    round(count(0) * 100 / sum(count(0)) over (partition by client), 2) as pct_attr,
    round(count(distinct page) * 100 / total, 2) as pct_pages
from
    `httparchive.almanac.summary_response_bodies`,
    unnest(regexp_extract_all(body, '(?i)<(video[^>]*)')) as video,
    unnest(
        regexp_extract_all(
            video,
            '(?i)(autoplay|autoPictureInPicture|buffered|controls|controlslist|crossorigin|use-credentials|currentTime|disablePictureInPicture|disableRemotePlayback|duration|height|intrinsicsize|loop|muted|playsinline|poster|preload|src|width)'
        )
    ) as attr
join
    (
        select _table_suffix as client, count(0) as total
        from `httparchive.summary_pages.2019_07_01_*`
        group by _table_suffix
    ) using (client)
where date = '2019-07-01' and firsthtml
group by client, total, attr
order by freq / total_attr desc
